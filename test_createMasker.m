function [masker,target,fs] = test_createMasker(options)
    

    current_dir = fileparts(mfilename('fullpath'));
    added_path  = {};

    added_path{end+1} = '~/Library/Matlab/auditory_research_tools/vocoder_2015';
    addpath(added_path{end});

    added_path{end+1} = '~/Library/Matlab/auditory_research_tools/STRAIGHTV40_006b';
    addpath(added_path{end});

    added_path{end+1} = '~/Library/Matlab/auditory_research_tools/common_tools';
    addpath(added_path{end});
    
    
    %Take random pieces of masker sentences and stitch them together.
    %Target should be zero padded to start 0.5sec after the masker.
    %Target and masker should be the same length to be added later.

    stim_dir = options.sound_path;
    bank_start = options.masker(1);
    bank_end = options.masker(2);
    
    [target,fs] = audioread(['~/Library/Matlab/Sounds/VU_zinnen/Man/equalized' '/' '3.wav']);
    
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
        chunk = cosgate(chunk, fs, 2e-3);
        
        
        
        masker = [masker; chunk];
            
        
    end
    
    %Set masker length = target length:
    if length(masker) > length(target)
      
        masker = masker(1:length(target)); %chop it off if it is too long
      
    elseif length(masker) < length(target)
        
        masker = [masker; masker];
        masker = masker(1:length(target)); %sloppy solution! Must make it more robust!
        
    end
    
    %------------------------------------------
    %% Clean up the path

    for i=1:length(added_path)
        rmpath(added_path{i});
    end
end