%Create sample stimuli for Deniz:

%All modifications are done to masker. Target is not manipulated.

%% Set appropriate path

current_dir = fileparts(mfilename('fullpath'));
added_path  = {};

added_path{end+1} = '~/Library/Matlab/auditory-research-tools/vocoder_2015';
addpath(added_path{end});

added_path{end+1} = '~/Library/Matlab/auditory-research-tools/STRAIGHTV40_006b';
addpath(added_path{end});

added_path{end+1} = '~/Library/Matlab/auditory-research-tools/common_tools';
addpath(added_path{end});

%% Build Options:

[expe, options] = expe_build_conditions();

destPath = '/Users/dbaskent/Experiments/Nawal/S2_E1_SOS/S2_E1_SOS/Example Stimuli';
ext = '.wav';

%% Make Stim:

%1. F0s and VTLs: 4 conditions: F0 = 12, VTL = 4; F0 = 4, VTL = 12; F0 =
%4, VTL = 4; F0 = 12, VTL = 12; TMR = 5;

dir_voice = [8, 4, 2, 10];

    %Find 1st condition that fits criteria:
    for i = 1:length(dir_voice)
        
        % dir_voice = 8  --> F0 = 12, VTL = 4
        % dir_voice = 4  --> F0 = 4,  VTL = 12
        % dir_voice = 2  --> F0 = 4,  VTL = 4
        % dir_voice = 10 --> F0 = 12, VTL = 12
        i_condition = find([expe.test.conditions.done]==0 & [expe.test.conditions.dir_voice] == dir_voice(i), 1);

        trial = expe.test.conditions(i_condition);
        trial.TMR = 5;

        [target,masker,sentence,fs] = expe_make_stim(options,trial,'test');
        xOut = (target+masker)*10^(-options.attenuation_dB/20);

        f0 = options.test.voices(trial.dir_voice).f0;
        ser = options.test.voices(trial.dir_voice).ser;
        TMR = trial.TMR;
        %save filenames: Exi_TMR5_GPRx_SERy.wav
        fname = sprintf('Ex%d_TMR%d_GPR%.2f_SER%.2f_MaskerEnding_100ms_CosineRamp_250ms',i, TMR, f0, ser);
        fname = fullfile(destPath, [fname, ext]);
        audiowrite(fname,xOut,fs,'BitsPerSample',16);
    end

   

%2. 250-500 ms longer masker vs 100 ms; TMR = 5; F0 = 4, VTL = 4

    i_condition = find([expe.test.conditions.done]==0 & [expe.test.conditions.dir_voice] == dir_voice(3), 1);
    trial = expe.test.conditions(i_condition);
    trial.TMR = 5;

    [target,masker,sentence,fs] = expe_make_stim(options,trial,'test');
    xOut = (target+masker)*10^(-options.attenuation_dB/20);

    f0 = options.test.voices(trial.dir_voice).f0;
    ser = options.test.voices(trial.dir_voice).ser;
    TMR = trial.TMR;
                
%save filenames: 
%               Masker_ending_250ms_TMR_5_GPR_x_SER_y.wav
%               Masker_ending_500ms_TMR_5_GPR_x_SER_y.wav
                fname = sprintf('MaskerEnding_100ms_TMR%d_GPR%.2f_SER%.2f_CosineRamp_250ms', TMR, f0, ser);
                fname = fullfile(destPath, [fname, ext]);
                audiowrite(fname,xOut,fs,'BitsPerSample',16);

%3. cosine ramp difference: 250 ms vs 20 ms; TMR = 5, F0 = 4, VTL = 4

    i_condition = find([expe.test.conditions.done]==0 & [expe.test.conditions.dir_voice] == dir_voice(3), 1);
    trial = expe.test.conditions(i_condition);
    trial.TMR = 5;

    [target,masker,sentence,fs] = expe_make_stim(options,trial,'test');
    xOut = (target+masker)*10^(-options.attenuation_dB/20);

    f0 = options.test.voices(trial.dir_voice).f0;
    ser = options.test.voices(trial.dir_voice).ser;
    TMR = trial.TMR;

%save filenames: 
%               cosine_ramp_250ms_TMR_5_GPR_x_SER_y.wav
%               cosine_ramp_20ms_TMR_5_GPR_x_SER_y.wav
%               cosine_ramp_5ms_TMR_5_GPR_x_SER_y.wav              

                fname = sprintf('cosine_ramp_250ms_TMR%d_GPR%.2f_SER%.2f_MaskerEnding_100ms', TMR, f0, ser);
                fname = fullfile(destPath, [fname, ext]);
                audiowrite(fname,xOut,fs,'BitsPerSample',16);





