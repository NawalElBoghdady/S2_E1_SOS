function [target,masker,sentence,fs] = expe_make_stim(options,trial,phase,varargin)

    %phase needs to switch between training 1 (no masker), training 2 (masker)
    %and test. This parameter is set in expe_main.
    
    if strcmp(phase, 'training1')
        
        [target,sentence,fs] = createTarget(options,trial,phase,varargin{1});
        masker = zeros(length(target),1);
        
    elseif strcmp(phase, 'training2')
        
        [target,sentence,fs] = createTarget(options,trial,phase,varargin{1});
        [masker,target,fs] = createMasker(options,trial,'training',target,fs,varargin{1});
        
        
    elseif strcmp(phase, 'test')
        
        [target,sentence,fs] = createTarget(options,trial,phase);
        [masker,target,fs] = createMasker(options,trial,phase,target,fs);
        
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
    
    silence_gap_start = floor(0.5*fs); %500ms silence at the beginning of the target.
    silence_gap_end = floor(0.25*fs); %250ms silence at the end of the target.
    target = [zeros(silence_gap_start,1);target;zeros(silence_gap_end,1)]; %zero pad with silence gap of 500 ms at the beginning and 250 ms at the end.
    

end


function [masker,target,fs] = createMasker(options,trial,phase,target,fs,varargin)
 
   %Take random pieces of masker sentences and stitch them together.
    %Target and masker should be the same length to be added later.  

    stim_dir = options.tmp_path;
    
    sentence_bank = [];
    for i_masker_list = 1:length(options.masker)
        
        masker_list = options.masker(i_masker_list);
        masker_sentences = options.list{masker_list}(1):options.list{masker_list}(2);
        sentence_bank = [sentence_bank masker_sentences];
%         bank_start = options.masker(1);
%         bank_end = options.masker(2);
    end
    
    
    %Randomize sentences:
    
    %sentence_bank = bank_start:bank_end;
    %sentence_bank = sentence_bank(randperm(length(sentence_bank)));
    
    masker = [];
    
    while length(masker) < length(target)
        %Pick a random sentence from the masker sentence_bank:
        i = datasample(sentence_bank,1);
        
        f0 = options.(phase).voices(trial.dir_voice).f0;
        ser = options.(phase).voices(trial.dir_voice).ser;
        filename = make_fname([num2str(i) '.wav'], f0, ser, stim_dir);
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
        
        
    end
    
    
%   Set lenght of masker vector = length of target vector. This makes sure
%   that only the vectors are of equal length so that we could add them.
%   However, length of the masker SIGNAL (actual speech) and target SIGNAL
%   are NOT the same:
    if length(masker) >= length(target)
      
        masker = masker(1:length(target)); %chop it off if it is too long
        
    end
    
    masker = cosgate(masker, fs, 50e-3); %50ms cosine ramp to both beginning and end of masker signal.
    
    %Set masker RMS:
    rmsM = rms(masker);
    silence_start = floor(0.5*fs);
    silence_end = length(target)-floor(0.25*fs);
    rmsT = rms(target(silence_start:silence_end));
    masker = masker./rmsM.*(rmsT/10^(trial.TMR/20));
    

end

function fname = make_fname(wav, f0, ser, destPath)

    [~, name, ext] = fileparts(wav);
    
    fname = sprintf('M_%s_GPR%.2f_SER%.2f', name, f0, ser);
   
    fname = fullfile(destPath, [fname, ext]);
end






