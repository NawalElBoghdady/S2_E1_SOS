function createMasker_offline()

%Create Masker Straight matrices offline:

if is_test_machine() %If it's computer in Tinnitus Room
    disp('-------------------------');
    disp('--- In Tinnitus Room ---');
    disp('-------------------------');
    options.sound_path = '/Users/denizbaskent/Sounds/VU_zinnen/Vrouw/equalized';
    options.tmp_path   = '/Users/denizbaskent/Sounds/VU_zinnen/Vrouw/processed';

else %If it's experimenter's OWN computer:
    disp('-------------------------');
    disp('--- On coding machine ---');
    disp('-------------------------');
    options.sound_path = '~/Library/Matlab/Sounds/VU_zinnen/Vrouw/equalized';
    options.tmp_path   = '~/Library/Matlab/Sounds/VU_zinnen/Vrouw/processed';
end

    filename = fullfile(options.tmp_path, sprintf('options.mat'));
    options.filename = filename;
    
    
%-------------------------------------------------
%% Set appropriate path

current_dir = fileparts(mfilename('fullpath'));
added_path  = {};

added_path{end+1} = '~/Library/Matlab/auditory_research_tools/vocoder_2015';
addpath(added_path{end});

added_path{end+1} = '~/Library/Matlab/auditory_research_tools/STRAIGHTV40_006b';
addpath(added_path{end});

added_path{end+1} = '~/Library/Matlab/auditory_research_tools/common_tools';
addpath(added_path{end});


[expe, options] = expe_build_conditions(options);

tic()
for i = 1:length(expe.test.conditions)
    
    disp('-----------')
    disp(['File ' num2str(i)])
    
    [masker,fs] = createMasker(options,i);
    
end

toc()





end


function [masker,fs] = createMasker(options,i_condition)
    
    %Take random pieces of masker sentences and stitch them together.

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
    audiowrite(filename,masker,fs);
    createStraightMats(filename);
    
    

end


function createStraightMats(wavIn) 
    mat = strrep(wavIn, '.wav', '.straight.mat');

    if ~exist(mat, 'file')
        [x, fs] = audioread(wavIn);
        [f0, ap] = exstraightsource(x, fs);
       
        sp = exstraightspec(x, f0, fs);
        x_rms = rms(x);

        save(mat, 'fs', 'f0', 'sp', 'ap', 'x_rms');
    end
end

