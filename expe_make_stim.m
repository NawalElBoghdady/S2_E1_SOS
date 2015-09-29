function [target,masker,sentence,fs] = expe_make_stim(options,trial,phase,varargin)

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
        [masker,target,fs] = createMasker(options,trial,target,fs);
        
    end
    
    
end

function [target,sentence,fs] = createTarget(options,trial,phase,varargin)

    if strcmp(phase,'test')
        
        sentence = trial.test_sentence;
        
    elseif strcmp(phase,'training1') || strcmp(phase,'training2')

        sentence = trial.(phase).sentences(varargin{1})
    end
    
    wavIn = fullfile(options.sound_path, [num2str(sentence), '.wav']);
    
    [target,fs] = audioread(wavIn);
    
    silence_gap_start = floor(0.5*fs);
    silence_gap_end = floor(0.1*fs);
    target = [zeros(silence_gap_start,1);target]; %zero pad with silence gap of 500 ms at the beginning and 100 ms at the end.
    

end


function [masker,target,fs] = createMasker(options,trial,target,fs,varargin)
 
   %Take random pieces of masker sentences and stitch them together.
    %Target and masker should be the same length to be added later.  

    stim_dir = options.tmp_path;
    bank_start = options.masker(1);
    bank_end = options.masker(2);
    
    
    %Extract chunks from 4 random sentences. 4 was chosen to have a
    %masker that is almost always longer than (or as long as) the target. That way, it is easier
    %to chop up the masker at the end to make it as long as the target:
    %nsentences = 4;
    
    sentence_bank = bank_start:bank_end;
    sentence_bank = sentence_bank(randperm(length(sentence_bank)));
    
    masker = [];
    i = 1;
    
    while length(masker) < length(target)
        f0 = options.test.voices(trial.dir_voice).f0;
        ser = options.test.voices(trial.dir_voice).ser;
        filename = make_fname([num2str(sentence_bank(i)) '.wav'], f0, ser, stim_dir);
        [y,fs] = audioread(filename);
        
        %Take chunk sizes that are at least 1 sec long
        min_dur = 1; %1 sec
        max_dur = floor(length(y)/fs); %length of the whole sentence.
        r = floor((max_dur-min_dur).*rand(1,1) + min_dur);
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
        
        i = i+1;
        
    end
    
    
%    Set masker length = target length:
    if length(masker) >= length(target)
      
        masker = masker(1:length(target)); %chop it off if it is too long
      
%     elseif length(masker) < length(target)
%         
%         while length(masker) < length(target)
%             masker = [masker; masker];
%         end
%         masker = masker(1:length(target)); 
%         
%         if length(masker) ~= length(target)
%             error('We have a problem!!!');
%         end
        
    end
    
    masker = cosgate(masker, fs, 250e-3); %250ms cosine ramp.
    
    %Set masker RMS:
    rmsM = rms(masker);
    silence = floor(0.5*fs);
    rmsT = rms(target(silence:end));
    masker = masker./rmsM.*(rmsT/10^(trial.TMR/20));
    

end

function fname = make_fname(wav, f0, ser, destPath)

    [~, name, ext] = fileparts(wav);
    
    fname = sprintf('M_%s_GPR%.2f_SER%.2f', name, f0, ser);
   
    fname = fullfile(destPath, [fname, ext]);
end






