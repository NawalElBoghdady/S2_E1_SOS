function [target,masker,sentence,fs] = expe_make_stim(options,trial,phase)

    %phase needs to switch between training 1 (no masker), training 2 (masker)
    %and test. This parameter is set in expe_main.
    
    if strcmp(phase, 'training1')
        
        [target,sentence,fs] = createTarget(options,trial,phase);
        masker = zeros(length(target),1);
        
    elseif strcmp(phase, 'training2')
        
        [target,sentence,fs] = createTarget(options,trial,phase);
        [masker,target,fs] = createMasker(options,target,fs);
        
        
    elseif strcmp(phase, 'test')
        
        [target,sentence,fs] = createTarget(options,trial,phase);
        [masker,target,fs] = createMasker(options,target,fs);
        
    end
    
    
    
    
    
     %Set target-to-masker ratio (TMR): => this needs to be moved to
     %expe_main
%     attenuate = p.Target_rms / rms(target_signal);
%     target_signal = target_signal*attenuate;

end

function [target,sentence,fs] = createTarget(options,trial,phase)

    %Straight processing happens here!
    
    if strcmp(phase,'test')
        if trial.session == 1
            bank_start = options.testS1(1);
            bank_end = options.testS1(2);
        elseif trial.session == 2
            bank_start = options.testS2(1);
            bank_end = options.testS2(2);
        end
    elseif strcmp(phase,'training1') || strcmp(phase,'training2')
        bank_start = options.trainSentences(1);
        bank_end = options.trainSentences(2);
    end
    
    sentence_bank = bank_start:bank_end;
    sentence = sentence_bank(randperm(length(sentence_bank),1)); %randomly choose a target sentence from the test bank
    %NOTE: This does not guarantee that you don't choose the same sentence
    %more than once in a session!!!! Fix later!!
    
    f0 = options.test.voices(trial.dir_voice).f0;
    ser = options.test.voices(trial.dir_voice).ser;
    
    [y,fs] = straight_process(sentence, f0, ser, options, trial.vocoder);
    
    target = y;
                                                            
    
    

end


function [masker,target,fs] = createMasker(options,target,fs)
    
    %Take random pieces of masker sentences and stitch them together.
    %Target should be zero padded to start 0.5sec after the masker.
    %Target and masker should be the same length to be added later.

    stim_dir = options.sound_path;
    bank_start = options.masker(1);
    bank_end = options.masker(2);
    
    silence_gap = 0.5*fs;
    target = [zeros(silence_gap,1);target]; %zero pad with silence gap of 0.5 sec
    
    %Extract chunks from 15 random sentences. 15 was chosen to have a
    %masker that is always longer than the target. That way, it is easier
    %to chop up the masker at the end to make it as long as the target:
    nsentences = 15;
    chunk_size = 0.4; %take a 0.4th of each sentence
    
    sentence_bank = bank_start:bank_end;
    sentence_bank = sentence_bank(randperm(length(sentence_bank)));
    
    masker = [];
    
    %instead of concatenating the whole masker, concatenate new chunks.
    
    for i = 1:nsentences
        
        [y,fs] = audioread([stim_dir '/' num2str(sentence_bank(i)) '.wav']);
        chunk_length = floor(chunk_size*length(y)); %determine chunk size
        %start the chunk at a random location in the file:
        
        chunk_start = randperm(length(y),1);
        
        if chunk_start+chunk_length > length(y)
            chunk_ind = [chunk_start-chunk_length chunk_start];
        else
            chunk_ind = [chunk_start chunk_start+chunk_length];
        end
        
        chunk = y(chunk_ind(1):chunk_ind(2));
        
        %Apply cosine ramp:
        chunk = cosgate(chunk, fs, 2e-3); %2ms cosine ramp.
        
        masker = [masker; chunk];
            
        
    end
    
    %Set masker length = target length:
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
    masker = masker./rmsM.*(rmsT/10^(options.TMR/20));
    
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

function [y, fs] = straight_process(sentence, t_f0, ser, options, vocoder)

    wavIn = fullfile(options.sound_path, [num2str(sentence), '.wav']);
    wavOut = make_fname(vocoder, wavIn, t_f0, ser, options.tmp_path);

    if ~exist(wavOut, 'file')


        mat = strrep(wavIn, '.wav','.straight.mat');

        if exist(mat, 'file')
            load(mat);
        else
            [x, fs] = audioread(wavIn);
            [f0, ap] = exstraightsource(x, fs);
            
            sp = exstraightspec(x, f0, fs);
            x_rms = rms(x);

            save(mat, 'fs', 'f0', 'sp', 'ap', 'x_rms');
        end

        mf0 = exp(mean(log(f0(f0~=0))));

        f0(f0~=0) = f0(f0~=0) / mf0 * t_f0;

        p.frequencyAxisMappingTable = ser;
        y = exstraightsynth(f0, sp, ap, fs, p);

        y = y/rms(y)*x_rms;
        if max(abs(y))>1
            warning('Output was renormalized for "%s".', wavOut);
            y = 0.98*y/max(abs(y));
        end 

        audiowrite(wavOut, y, fs);

    else



        [y, fs] = audioread(wavOut);
        %[y, fs] = wavread(wavOut);
    end
end

function fname = make_fname(vocoder, wav, f0, ser, destPath)

    [~, name, ext] = fileparts(wav);
    
    %fname = sprintf('%s_%s_%s_GPR%d_SER%.2f', ['S' num2str(session)],['Voc-' vocoder] ,['Sentence-' name], floor(f0), ser);
    fname = sprintf('Sentence%s_Voc%s_GPR%d_SER%.2f', name, num2str(vocoder) , floor(f0), ser);
   
    fname = fullfile(destPath, [fname, ext]);
end







