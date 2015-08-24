function [options] = expe_process_stim_offline()
%% function [options] = expe_process_stim_offline()
%   Produce Straight matrices for the VU_Zinnen offline to save time during experiment

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

    

%     options = expe_build_conditions(options); %to make sure you process the sound files according to the specified options.
% 
%     if isfield(options, 'filename')
%         save(options.filename, 'options');
% 
%     else
%         warning('The test file was not saved: no filename provided.');
%     end
%     


allFiles = dir(options.sound_path);
allNames = {allFiles(~[allFiles.isdir]).name};

for i = 1:length(allNames)
    
    if ~strcmp(allNames{i},'.DS_Store') && ~isempty(strfind(allNames{i},'.wav'))
        
        disp('--------')
        disp(allNames{i})
        wavfilename = [options.sound_path '/' allNames{i}];
        createStraightMats(wavfilename);
        
    end
end
    
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



