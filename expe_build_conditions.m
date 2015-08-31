function [expe, options] = expe_build_conditions(options)

options.instructions.start = ['We want to test your understanding of speech in the presence of another speaker.\n'...
    'The target sentence you have to repeat will start half a second after the masking speech.\n'...
    'The background speech will be made of chopped up words that should not make much sense.\n'...
    'Your task is to repeat the target sentence. Your spoken responses will be recorded for further analyses.\n\n'...
    '-------------------------------------------------\n\n'...
    ''];

options.instructions.training1 = ['You will now listen to ONLY the target speaker \n'...
    'just to get acquainted with how he/she sounds like.\n Please repeat the sentence.\n\n'...
    '-------------------------------------------------\n\n'...
    ''];

options.instructions.training2 = ['You will now listen to samples of BOTH the target speaker AND \n'...
    'the masker just to get used to the task.\n Please repeat the target sentence.\n\n'...
    '-------------------------------------------------\n\n'...
    ''];
options.instructions.test = ['You will now begin the actual test.\n'...
    'The target sentence you have to repeat will start half a second after the masking speech.\n'...
    'The background speech will be made of chopped up words that should not make much sense.\n'...
    'Your task is to repeat the target sentence. Your spoken responses will be recorded for further analyses.\n\n'...
    '-------------------------------------------------\n\n'...
    ''];

options.instructions.vocoded = ['All the following sounds will now be a simulation of what\n'...
    'Cochlear Implant subjects hear. For this reason, all sounds will be very distorted.\n\n'...
    '-------------------------------------------------\n\n'];

options.instructions.listen = ['Listen carefully to the target sentence.\n\n'...
    '-------------------------------------------------\n\n'];

options.instructions.repeat = ['Now repeat the target sentence.\n\n'...
    '-------------------------------------------------\n\n'];

options.instructions.feedback = ['This is the correct sentence.\n\n'...
    '-------------------------------------------------\n'];





test_machine = is_test_machine();

if test_machine %If it's computer in Tinnitus Room
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

%% ----------- Signal options
options.fs = 44100;
if test_machine
    options.attenuation_dB = 3; % General attenuation
else
    options.attenuation_dB = 3; % General attenuation
end
options.ear = 'both'; % right, left or both

%% ----------- Design specification
options.test.n_repeat = 3; % Number of repetitions per condition

%% ----------- Stimuli options
%options.test.f0s  = [242, 121, round(242*2^(5/12))]; 
%options.test.sers = [1, 2^(-3.8/12), 2^(5/12)];

options.test.voices(1).label = 'female'; % 130.26 = average pitch of original female voice
options.test.voices(1).f0 = 130.26;
options.test.voices(1).ser = 1;

options.test.voices(2).label = 'child-vtl-0';
options.test.voices(2).f0 = options.test.voices(1).f0;
options.test.voices(2).ser = 1;

options.test.voices(3).label = 'child-vtl-0p75';
options.test.voices(3).f0 = options.test.voices(1).f0;
options.test.voices(3).ser = 2^(0.75/12);

options.test.voices(4).label = 'child-vtl-1p5';
options.test.voices(4).f0 = options.test.voices(1).f0;
options.test.voices(4).ser = 2^(1.75/12);

options.test.voices(5).label = 'child-vtl-4';
options.test.voices(5).f0 = options.test.voices(1).f0;
options.test.voices(5).ser = 2^(4/12);

options.test.voices(6).label = 'child-vtl-9';
options.test.voices(6).f0 = options.test.voices(1).f0;
options.test.voices(6).ser = 2^(9/12);

options.test.voices(7).label = 'child-vtl-15';
options.test.voices(7).f0 = options.test.voices(1).f0;
options.test.voices(7).ser = 2^(15/12);

options.training.voices = options.test.voices;
options.training.nsentences = 3; %number of training sentences per condition.

%--- Define sentence bank for each stimulus type: 
options.trainSentences = [1 147];               %training sentences (target)
options.testS1 = [148 294];                     %test sentences Session 1 (target)
options.testS2 = [295 441];                     %test sentences Session 2 (target)
options.masker = [442 507];                     %masker sentences training+test all sessions
options.sentence_bank = 'VU_zinnen_vrouw.mat';  %Where all sentences in the vrouw database are stored as string.
%options.TMR = 
%This protocol was adopted from Mike and Nikki's Musician effect on SOS
%performance

%--- Voice pairs
% [ref_voice, dir_voice]
options.test.voice_pairs = [...
    1 2;  % Female -> Child VTL 0 ST
    1 3;  % Female -> Child VTL 0.75 ST
    1 4;  % Female -> Child VTL 1.5 ST
    1 5;  % Female -> Child VTL 4 ST
    1 6;  % Female -> Child VTL 9 ST
    1 7]; % Female -> Child VTL 15 ST
options.training.voice_pairs = options.test.voice_pairs;

%% --- Vocoder options

% Base parameters
p = struct();
p.envelope = struct();
p.envelope.method = 'low-pass';
p.envelope.rectify = 'half-wave';
p.envelope.order = 2;

p.synth = struct();
p.synth.carrier = 'noise';
p.synth.filter_before = false;
p.synth.filter_after  = true;
p.synth.f0 = 1;

p.envelope.fc = 300;

vi = 1; %vocoder index (how many vocoder instances u are simulating)
vo = 1; %butterworth filter order fixed to 4th order.

nc = 16; %run for 16 chs only
elec_array = struct('type','AB-HiFocus','ins_depth',[],'tot_length',24.5,'e_width',0.4,'e_spacing',0.85,'nchs',16, 'active_length',15.5);
c_length = 35; %33 mm average cochlear length

range = [170 8700];
tables = {'hr90k'};

ins_depth = 21.5; %shallow = 18.5mm, %deep insertion = 21.5mm for HiFocus => data from AB surgeon's guide for HiRes90K implant

for i = 1:length(ins_depth)  
    
    elec_array.ins_depth = ins_depth(i);
    x = e_loc(elec_array,c_length);
    
    for i_freq_table = 1:length(tables) %loop on the type of frequency tables 

        p.analysis_filters  = estfilt_shift(nc, tables{i_freq_table}, options.fs, range, vo);
        p.synthesis_filters = estfilt_shift(nc, 'greenwood', options.fs, x, vo);

        options.vocoder(vi).label = sprintf('n-%dch-%dord-%gmm', nc, 4*vo, ins_depth(i));
        options.vocoder(vi).description = sprintf('Noise-band vocoder, type %s ,%i bands from %d to %d Hz, insertion depth %g mm, order %i, %i Hz envelope cutoff.',...
            tables{i_freq_table}, nc, range(1),range(2) ,ins_depth(i), 4*vo, p.envelope.fc);
        options.vocoder(vi).parameters = p;

        vi = vi +1;
    end
end



%% Build Experimental Conditions:

load VU_zinnen_vrouw.mat;
rndSequence = randperm(length(VU_zinnen_vrouw));


%================================================== Build test block

test = struct();

for i_vp = randperm(size(options.test.voice_pairs, 1))
    for session = 1:2
        for ir = 1:options.test.n_repeat
            for i_voc = 0:length(options.vocoder) %0 to indicate non-vocoded condition

                condition = struct();

                condition.ref_voice = options.test.voice_pairs(i_vp, 1);
                condition.dir_voice = options.test.voice_pairs(i_vp, 2);           

                condition.vocoder = i_voc;

                condition.visual_feedback = 0;
                
                condition.session = session;

                % Do not remove these lines
                condition.i_repeat = ir;
                condition.done = 0;

                if ~isfield(test,'conditions')
                    test.conditions = orderfields(condition);
                else
                    test.conditions(end+1) = orderfields(condition);
                end

            end
        end
    end
end

% Randomization of the order
%test.conditions = test.conditions(randperm(length(test.conditions)));


%====================================== Create the expe structure and save

expe.test = test;

%--
                
if isfield(options, 'res_filename')
    save(options.res_filename, 'options', 'expe');
    
else
    warning('The test file was not saved: no filename provided.');
end

%%%%%%%%%%%%%%%%%%%%%%%%
%RECORD AUDIO RESPONSES:
%recObj = audiorecorder
%disp('Start speaking.')
%recordblocking(recObj, 5);
%disp('End of Recording.');
%play(recObj);
%y = getaudiodata(recObj);
%fs = recObj.SampleRate;
%%%%%%%%%%%%%%%%%%%%%%%


