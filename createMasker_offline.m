function createMasker_offline()

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






end