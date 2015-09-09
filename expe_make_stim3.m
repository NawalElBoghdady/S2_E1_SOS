function [target,masker,sentence,fs] = expe_make_stim3(options,trial,phase,varargin)

    %phase needs to switch between training 1 (no masker), training 2 (masker)
    %and test. This parameter is set in expe_main.
    
    if strcmp(phase, 'training1')
        
        [target,sentence,fs] = createTarget(options,trial,phase,varargin{1});
        masker = zeros(length(target),1);
        
    elseif strcmp(phase, 'training2')
        
        [target,sentence,fs] = createTarget(options,trial,phase,varargin{1});
        [masker,target,fs] = createMasker(options,trial,target,fs,varargin{1});
        
        
    elseif strcmp(phase, 'test')
        
        [target,sentence,fs] = createTarget(options,trial,phase);
        [masker,target,fs] = createMasker(options,trial,target,fs,varargin{1});
        
    end
    
    
end

function [target,sentence,fs] = createTarget(options,trial,phase,varargin)

    if strcmp(phase,'test')
        
        sentence = trial.test_sentence;
        
    elseif strcmp(phase,'training1') || strcmp(phase,'training2')

        sentence = trial.(phase).sentences(varargin{1});
    end
    
    wavIn = fullfile(options.sound_path, [num2str(sentence), '.wav']);
    
    [target,fs] = audioread(wavIn);
    
    silence_gap = 0.5*fs;
    target = [zeros(silence_gap,1);target]; %zero pad with silence gap of 0.5 sec
    

end


function [masker,target,fs] = createMasker(options,trial,target,fs,i_condition)
 
   %Take random pieces of masker sentences and stitch them together.
    %Target and masker should be the same length to be added later.  

    stim_dir = options.sound_path;
    bank_start = options.masker(1);
    bank_end = options.masker(2);
    
    
    %Extract chunks from 4 random sentences. 4 was chosen to have a
    %masker that is almost always longer than (or as long as) the target. That way, it is easier
    %to chop up the masker at the end to make it as long as the target:
    nsentences = 4;
    
    sentence_bank = bank_start:bank_end;
    sentence_bank = sentence_bank(randperm(length(sentence_bank)));
    
    masker = [];
    
    for i = 1:nsentences
        
        [y,fs] = audioread([stim_dir '/' num2str(sentence_bank(i)) '.wav']);
        %chunk_length = floor(chunk_size*length(y)); %determine chunk size
        
        %Take chunk sizes that are at least 1 sec long
        min_dur = 1; %1 sec
        max_dur = floor(length(y)/fs); %length of the whole sentence.
        r = (max_dur-min_dur).*rand(1,1) + min_dur;
        chunk_size = r*fs; %take chunk sizes of min 1 sec from each sentence
        
        
        %start the chunk at a random location in the file: 
        chunk_start = randperm(length(y),1);
        
        if chunk_start+chunk_size > length(y)
            if chunk_start-chunk_size < length(y)
                chunk_ind = [1 chunk_size];
            else
                chunk_ind = [chunk_start-chunk_size chunk_start];
            end
        
        else
            chunk_ind = [chunk_start chunk_start+chunk_size];
        end
        
        chunk = y(chunk_ind(1):chunk_ind(2));
        
        %Apply cosine ramp:
        chunk = cosgate(chunk, fs, 2e-3); %2ms cosine ramp.
        
        masker = [masker; chunk];
            
        
    end
    
    
    filename = [options.tmp_path '/' 'M_' num2str(i_condition) '.wav'];
%     audiowrite(filename,masker,fs);
%     createStraightMats(filename);
    
    

end

    %sentence = ['M_' num2str(i_condition)];
    
    
%    Set masker length = target length:
    if length(masker) >= length(target)
      
        masker = masker(1:length(target)); %chop it off if it is too long
      
    elseif length(masker) < length(target)
        
        while length(masker) < length(target)
            masker = [masker; masker];
        end
        masker = masker(1:length(target)); 
        
        if length(masker) ~= length(target)
            error('We have a problem!!!');
        end
        
    end
    
    %Set masker RMS:
    rmsM = rms(masker);
    rmsT = rms(target);
    masker = masker./rmsM.*(rmsT/10^(trial.TMR/20));
    
%     switch options.ear
%         case 'right'
%             masker  = [zeros(size(masker)), masker];
%         case 'left'
%             masker = [masker, zeros(size(masker))];
%         case 'both'
%             masker = repmat(masker, 1, 2);
%         otherwise
%             error(sprintf('options.ear="%s" is not implemented', options.ear));
%     end
    

end

% function [y, fs] = straight_process(sentence, t_f0, ser, options, vocoder)
% 
%     wavIn = fullfile(options.tmp_path, [num2str(sentence), '.wav']);
%     wavOut = make_fname(vocoder, wavIn, t_f0, ser, options.tmp_path);
% 
%     if ~exist(wavOut, 'file')
% 
% 
%         mat = strrep(wavIn, '.wav','.straight.mat');
% 
%         if exist(mat, 'file')
%             load(mat);
%         else
%             [x, fs] = audioread(wavIn);
%             [f0, ap] = exstraightsource(x, fs);
%             
%             sp = exstraightspec(x, f0, fs);
%             x_rms = rms(x);
% 
%             save(mat, 'fs', 'f0', 'sp', 'ap', 'x_rms');
%         end
% 
%         %mf0 = exp(mean(log(f0(f0~=0))));
% 
%         %f0(f0~=0) = f0(f0~=0) / mf0 * t_f0;
%         f0(f0~=0) = f0(f0~=0) .* t_f0;
% 
%         p.frequencyAxisMappingTable = ser;
%         y = exstraightsynth(f0, sp, ap, fs, p);
% 
%         y = y/rms(y)*x_rms;
%         if max(abs(y))>1
%             warning('Output was renormalized for "%s".', wavOut);
%             y = 0.98*y/max(abs(y));
%         end 
% 
%         audiowrite(wavOut, y, fs);
% 
%     else
% 
% 
% 
%         [y, fs] = audioread(wavOut);
%         %[y, fs] = wavread(wavOut);
%     end
% end

function fname = make_fname(vocoder, wav, f0, ser, destPath)

    [~, name, ext] = fileparts(wav);
    
    %fname = sprintf('%s_%s_%s_GPR%d_SER%.2f', ['S' num2str(session)],['Voc-' vocoder] ,['Sentence-' name], floor(f0), ser);
    fname = sprintf('%s_Voc%s_GPR%d_SER%.2f', name, num2str(vocoder) , floor(f0), ser);
   
    fname = fullfile(destPath, [fname, ext]);
end







