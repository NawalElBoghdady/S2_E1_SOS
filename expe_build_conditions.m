function [expe, options] = expe_build_conditions(options)
% Creates the options and expe structs. Those contain all conditions and
% params that are needed for the experiment.

%% ----------- Define subject group: 0=> NH; 1=> CI

subj_group = 1;

%% ----------- Create Instructions
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
options.instructions.test = ['You will now begin the actual test. The target sentence you have to repeat \n'...
    'will start half a second after the masking speech. The background speech will be made of chopped up words '...
    'that should not make much sense. Your task is to repeat the target sentence.\nYour spoken responses will be '...
    'recorded for further analyses.\n'...
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

options.instructions.end = ['Congratulations!! This session is over. Thanks for participating.\n\n'...
    '-------------------------------------------------\n'];

options.instructions.breaktime = ['And now it''s time for a 5min break. Please leave everything as is. When you''re\n'...
    'ready to proceed, please click the ''CONTINUE'' button below.\n\n'...
    '-------------------------------------------------\n'];





test_machine = is_test_machine();

if test_machine %If it's computer in Tinnitus Room
    disp('-------------------------');
    disp('--- In Tinnitus Room ---');
    disp('-------------------------');
    options.sound_path = '/Users/dbaskent/Sounds/VU_zinnen/Vrouw/equalized';
    options.tmp_path   = '/Users/dbaskent/Sounds/VU_zinnen/Vrouw/processed';

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
options.test.nsentences = 13; % Number of test sentences per condition

%% ----------- Stimuli options

options.test.voices(1).label = 'female'; % 130.26 = average pitch of original female voice
options.test.voices(1).f0 = 1;
options.test.voices(1).ser = 1;

options.test.f0s  = [4, 9, 12]; 
options.test.vtls = [4, 9, 12];

options.test.voices(1).label = 'female'; % 130.26 = average pitch of original female voice
options.test.voices(1).f0 = 1;
options.test.voices(1).ser = 1;

i_voices = 2;

for i_f0 = 1:length(options.test.f0s)
    
    for i_vtl = 1:length(options.test.vtls)
        
        options.test.voices(i_voices).label = ['f0-' num2str(options.test.f0s(i_f0)) '-vtl-' num2str(options.test.vtls(i_vtl))];
        options.test.voices(i_voices).f0 = 2^(options.test.f0s(i_f0)/12);
        options.test.voices(i_voices).ser = 2^(options.test.vtls(i_vtl)/12);
        
        i_voices = i_voices + 1;
    end
    
end

%--- Voice pairs
% [ref_voice, dir_voice]
options.test.voice_pairs = [ones(length(options.test.voices),1), (1:length(options.test.voices))'];

%--- Define training voices:
% F0 = 8 ST, VTL = 8 ST
options.training.voices(1).label = 'f0-8-vtl-8';
options.training.voices(1).f0 = 2^(8/12); 
options.training.voices(1).ser = 2^(8/12);
options.training.nsentences = 6; %number of training sentences per condition.
options.training.TMR = 12; %dB
options.training.voice_pairs = [ones(length(options.training.voices),1), (1:length(options.training.voices))'];
%% --- Define sentence bank for each stimulus type:

%1. Define the lists:
options.sentence_bank = 'VU_zinnen_vrouw.mat';  %Where all sentences in the vrouw database are stored as string.
options.list = {''};
[~,name,~] = fileparts(options.sentence_bank);
sentences = load(options.sentence_bank,name);
sentences = sentences.(name);


for i = 1:13:length(sentences)
    if i == 1
        options.list{end} = [i i+12];
    else
        options.list{end+1} = [i i+12];
    end
end

%2. Define the sentence bank for each stimulus type:
options.trainSentences = [22:24];            %indices of training lists (target)
options.testS1 = [1:12 14:20 25 26];                     %indices of test lists Session 1 (target)
options.testS2 = options.testS1;                    %indices of test lists Session 2 (target)
options.masker = [options.list{27}(1) options.list{31}(2)];                    %masker sentences training+test all sessions



if subj_group == 0
    %--- Define Target-to-Masker Ratio in dB:
    options.unVocTMR = [-8 -4 0];
    options.VocTMR = [0 2 6 12];
    %This protocol was adopted from Mike and Nikki's Musician effect on SOS
    %performance; TMR values taken from Pals et al. 2015, and Stickney et al.
    %2004



    %% --- Vocoder options

    % Base parameters
    p = struct();
    p.envelope = struct();
    p.envelope.method = 'low-pass';
    p.envelope.rectify = 'half-wave';
    p.envelope.order = 2; %4th order envelope

    p.synth = struct();
    p.synth.carrier = 'noise';
    p.synth.filter_before = false;
    p.synth.filter_after  = true;
    p.synth.f0 = 1;

    p.envelope.fc = 200;

    vi = 1; %vocoder index (how many vocoder instances u are simulating)
    vo = 3; %butterworth filter order fixed to 12th order.

    nc = 8; %run for 8 chs only

    range = [150 7000];
    carriers = {'noise','sin'};


    for i = 1:length(carriers) %loop on the different carriers


                p.synth.carrier = carriers{i};
                p.analysis_filters  = estfilt_shift(nc, 'greenwood', options.fs, range, vo);
                p.synthesis_filters = estfilt_shift(nc, 'greenwood', options.fs, range, vo);

                options.vocoder(vi).label = sprintf('n-%dch-%dord', nc, 4*vo);
                options.vocoder(vi).description = sprintf('%s vocoder, type %s ,%i bands from %d to %d Hz, order %i, %i Hz envelope cutoff.',...
                    p.synth.carrier,'greenwood', nc, range(1),range(2) , 4*vo, p.envelope.fc);
                options.vocoder(vi).parameters = p;
                vi = vi +1;

    end
    
elseif subj_group == 1
    
    %--- No vocoding should be used:
    options.vocoder = [];
    
    %--- Define Target-to-Masker Ratio in dB:
    options.unVocTMR = [5 10 15];
    options.VocTMR = [5 10 15];
    %This protocol was adopted from Mike and Nikki's Musician effect on SOS
    %performance; TMR values taken from Pals et al. 2015, and Stickney et al.
    %2004
    
end


%% Build Experimental Conditions:

rng('shuffle');

%================================================== Build training block
training = struct();

%3. Define the training sentences:
trainList = datasample(options.trainSentences,1); %Randomly select a list
trainseq = datasample(options.list{trainList}(1):options.list{trainList}(2),options.training.nsentences*2,'Replace',false); %Randomly select n*2 sentences from the list

training.training1.sentences = [trainseq(1:options.training.nsentences)];
training.training2.sentences = [trainseq(options.training.nsentences+1:end)];
training.train_list = trainList;

training.ref_voice = options.training.voice_pairs(1, 1);
training.dir_voice = options.training.voice_pairs(1, 2);
training.TMR = options.training.TMR;

expe.training = training;


%================================================== Build test block

test = struct();

for session = 1
    
    i_condition = 1; %count the number of conditions needed
    
    rnd_voice_pairs = randperm(size(options.test.voice_pairs, 1));
    
    rnd_voice_pairs = rnd_voice_pairs(rnd_voice_pairs ~= 1); %discard the 0 vtl- 0 F0 condition when testing with a fixed TMR


    %1. Randomize Vocoders
    RandVocInd = randperm(length(options.vocoder));
    Vocs = 1:length(options.vocoder); 
    RandVocs = Vocs(RandVocInd);
    
    %2. Randomize the test list order:
    n_session = ['testS' num2str(session)];   
    testList = options.(n_session);

    rand_testList = datasample(testList,length(testList),'Replace',false); %shuffle the order of the test lists
    
    
    for i_voc = [0 RandVocs] %0 to indicate the non-vocoded condition 
        
        %2. Randomize TMRs
        RandunVocTMRind = randperm(length(options.unVocTMR));
        RandunVocTMR = options.unVocTMR(RandunVocTMRind);

        RandVocTMRind = randperm(length(options.VocTMR));
        RandVocTMR = options.VocTMR(RandVocTMRind);

        if i_voc == 0
            RandTMR = RandunVocTMR;
        else
            RandTMR = RandVocTMR;
        end
        
        for i_TMR = RandTMR
            
            ind_testList = rand_testList(i_condition);
            test_sentences = options.list{ind_testList}(1):options.list{ind_testList}(2);
            
            %Randomize the test sentences within a list:
            test_sentences = datasample(test_sentences,length(test_sentences),'Replace',false);
            
            %3. Define the training sentences:
            trainList = datasample(options.trainSentences,1); %Randomly select a list
            trainseq = datasample(options.list{trainList}(1):options.list{trainList}(2),options.training.nsentences*2,'Replace',false); %Randomly select n*2 sentences from the list
            
            for i_sent = test_sentences

                condition = struct();

                condition.session = session;
                condition.vocoder = i_voc;

                condition.TMR = i_TMR;

                condition.test_sentence = i_sent;
                condition.test_list = ind_testList;
                
                condition.ref_voice = options.test.voice_pairs(1, 1);

                condition.dir_voice = options.test.voice_pairs(1, 2);

                condition.training1.sentences = [trainseq(1:options.training.nsentences)];
                condition.training2.sentences = [trainseq(options.training.nsentences+1:end)];
                condition.train_list = trainList;


                condition.done = 0;

                condition.visual_feedback = 0;


                if ~isfield(test,'conditions')
                    test.conditions = condition;
                else
                    test.conditions(end+1) = condition;
                end

            end
            
            i_condition = i_condition+1; %increment the counter.
            
        end
        
        
        for i_vp = rnd_voice_pairs
                
            ind_testList = rand_testList(i_condition);
            test_sentences = options.list{ind_testList}(1):options.list{ind_testList}(2);
            
            %Randomize the test sentences within a list:
            test_sentences = datasample(test_sentences,length(test_sentences),'Replace',false);
            
            %3. Define the training sentences:
            trainList = datasample(options.trainSentences,1); %Randomly select a list
            trainseq = datasample(options.list{trainList}(1):options.list{trainList}(2),options.training.nsentences*2,'Replace',false); %Randomly select n*2 sentences from the list

            for i_sent = test_sentences

                condition = struct();

                condition.session = session;
                condition.vocoder = i_voc;

                condition.TMR = options.unVocTMR(2);

                condition.test_sentence = i_sent;
                condition.test_list = ind_testList;

                condition.ref_voice = options.test.voice_pairs(i_vp, 1);

                condition.dir_voice = options.test.voice_pairs(i_vp, 2);

                condition.training1.sentences = [trainseq(1:options.training.nsentences)];
                condition.training2.sentences = [trainseq(options.training.nsentences+1:end)];
                condition.train_list = trainList;


                condition.done = 0;

                condition.visual_feedback = 0;


                if ~isfield(test,'conditions')
                    test.conditions = condition;
                else
                    test.conditions(end+1) = condition;
                end

            end

            i_condition = i_condition+1; %increment the counter.
        end
        
    end
end

%Randomize all:
test.conditions = test.conditions(randperm(length(test.conditions)));
%====================================== Create the expe structure and save

expe.test = test;

%--
                
if isfield(options, 'res_filename')
    save(options.res_filename, 'options', 'expe');
    
else
    warning('The test file was not saved: no filename provided.');
end




