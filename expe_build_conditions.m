function [expe, options] = expe_build_conditions(options)
% Creates the options and expe structs. Those contain all conditions and
% params that are needed for the experiment.


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
options.test.nsentences = 3; % Number of test sentences per condition

%% ----------- Stimuli options
%options.test.f0s  = [242, 121, round(242*2^(5/12))]; 
%options.test.sers = [1, 2^(-3.8/12), 2^(5/12)];

options.test.voices(1).label = 'female'; % 130.26 = average pitch of original female voice
options.test.voices(1).f0 = 130.26;
options.test.voices(1).ser = 1;

% options.test.voices(2).label = 'child-vtl-0';
% options.test.voices(2).f0 = options.test.voices(1).f0;
% options.test.voices(2).ser = 2^(0/12);
% 
% options.test.voices(3).label = 'child-vtl-0p75';
% options.test.voices(3).f0 = options.test.voices(1).f0;
% options.test.voices(3).ser = 2^(0.75/12);
% 
% options.test.voices(4).label = 'child-vtl-1p5';
% options.test.voices(4).f0 = options.test.voices(1).f0;
% options.test.voices(4).ser = 2^(1.5/12);
% 
% options.test.voices(5).label = 'child-vtl-4';
% options.test.voices(5).f0 = options.test.voices(1).f0;
% options.test.voices(5).ser = 2^(4/12);
% 
% options.test.voices(6).label = 'child-vtl-9';
% options.test.voices(6).f0 = options.test.voices(1).f0;
% options.test.voices(6).ser = 2^(9/12);
% 
% options.test.voices(7).label = 'child-vtl-15';
% options.test.voices(7).f0 = options.test.voices(1).f0;
% options.test.voices(7).ser = 2^(15/12);

options.training.voices = options.test.voices;
options.training.nsentences = 3; %number of training sentences per condition.

%--- Voice pairs
% [ref_voice, dir_voice]
options.test.voice_pairs = [...
      1 1]; % Female -> Female condition.
%     1 2;  % Female -> Child VTL 0 ST
%     1 3;  % Female -> Child VTL 0.75 ST
%     1 4;  % Female -> Child VTL 1.5 ST
%     1 5;  % Female -> Child VTL 4 ST
%     1 6;  % Female -> Child VTL 9 ST
%     1 7]; % Female -> Child VTL 15 ST
options.training.voice_pairs = options.test.voice_pairs;

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
options.trainSentences = [options.list{21}(1) options.list{26}(2)];            %training sentences (target)
options.testS1 = [options.list{3}(1) options.list{11}(2)];                     %test sentences Session 1 (target)
options.testS2 = [options.list{12}(1) options.list{20}(2)];                    %test sentences Session 2 (target)
options.masker = [options.list{27}(1) options.list{31}(2)];                    %masker sentences training+test all sessions



%--- Define Target-to-Masker Ratio in dB:
options.unVocTMR = [-8 -5 0];
options.VocTMR = [0 5 10 15 20];
%This protocol was adopted from Mike and Nikki's Musician effect on SOS
%performance; TMR values taken from Pals et al. 2015, and Stickney et al.
%2004



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

range = [200 8700];
tables = {'hr90k','greenwood'};

ins_depth = 21.5; %shallow = 18.5mm, %deep insertion = 21.5mm for HiFocus => data from AB surgeon's guide for HiRes90K implant

%for i = 1:length(ins_depth)  
    
elec_array.ins_depth = ins_depth;
x = e_loc(elec_array,c_length);

for i_freq_table = 1:length(tables) %loop on the type of frequency tables
    
    if strcmp(tables{i_freq_table},'hr90k')

        p.analysis_filters  = estfilt_shift(nc, tables{i_freq_table}, options.fs, range, vo);
        p.synthesis_filters = estfilt_shift(nc, 'greenwood', options.fs, x, vo);

        options.vocoder(vi).label = sprintf('n-%dch-%dord-%gmm', nc, 4*vo, ins_depth);
        options.vocoder(vi).description = sprintf('Noise-band vocoder, type %s ,%i bands from %d to %d Hz, insertion depth %g mm, order %i, %i Hz envelope cutoff.',...
            tables{i_freq_table}, nc, range(1),range(2) ,ins_depth, 4*vo, p.envelope.fc);
        options.vocoder(vi).parameters = p;
        vi = vi +1;
        
    elseif strcmp(tables{i_freq_table},'greenwood')
        
        for nchs = [4 8]
            
            p.analysis_filters  = estfilt_shift(nchs, tables{i_freq_table}, options.fs, range, vo);
            p.synthesis_filters = estfilt_shift(nchs, 'greenwood', options.fs, range, vo);

            options.vocoder(vi).label = sprintf('n-%dch-%dord', nchs, 4*vo);
            options.vocoder(vi).description = sprintf('Noise-band vocoder, type %s ,%i bands from %d to %d Hz, order %i, %i Hz envelope cutoff.',...
                tables{i_freq_table}, nchs, range(1),range(2) , 4*vo, p.envelope.fc);
            options.vocoder(vi).parameters = p;
            vi = vi +1;

        end
    end
end
%end



%% Build Experimental Conditions:

rng('shuffle');
rndSequence = randperm(size(options.test.voice_pairs, 1));


%------Choose training sentences:
%1. Randomize the training sentences:
trainSeq = options.trainSentences(1):options.trainSentences(2);
rand_ind_trainSeq = randperm(length(trainSeq));
trainSeq = trainSeq(rand_ind_trainSeq);

%2. Choose 'options.test.voice_pairs' groups of 'training.nsentences'. Each
%voice-pair group should have a different set of nsentences so that
%training sentences 
ngroups = length(options.test.voice_pairs);
nsents = options.training.nsentences;

rand_train1_seq = {''};

for i = 1:nsents:ngroups*nsents*2*vi %voice_dirs*n_sentences*n_sessions*n_vocoders 
    
        if i == 1
            rand_train1_seq{end} = [trainSeq(i) trainSeq(i+1) trainSeq(i+2)];
        else
            rand_train1_seq{end+1} = [trainSeq(i) trainSeq(i+1) trainSeq(i+2)];
        end
        
end

rand_train2_seq = flip(rand_train1_seq);


%3. Randomize TMRs
RandunVocTMRind = randperm(length(options.unVocTMR));
RandunVocTMR = options.unVocTMR(RandunVocTMRind);

RandVocTMRind = randperm(length(options.VocTMR));
RandVocTMR = options.VocTMR(RandVocTMRind);

%4. Randomize Vocoders
RandVocInd = randperm(length(options.vocoder));
Vocs = 1:length(options.vocoder); 
RandVocs = Vocs(RandVocInd);

%================================================== Build test block

test = struct();



for session = 1:2
    
    s = 1; %counter for indexing sent_seq
    
    %Choose test sentences:
    bank = ['testS' num2str(session)];   
    sent_seq = options.(bank)(1):options.(bank)(2);
   
    rand_sent_seq = datasample(sent_seq,length(sent_seq),'Replace',false); %shuffle the order of the sentences
    
    for i_voc = [0 RandVocs] %0 to indicate non-vocoded condition 
        
        itmr = 1;
        
        if i_voc == 0
            RandTMR = RandunVocTMR;
        else
            RandTMR = RandVocTMR;
        end
        
        for i_TMR = RandTMR
    
            
            for i_vp = rndSequence

                for ir = 1:options.test.nsentences


                    condition = struct();

                    condition.session = session;
                    condition.vocoder = i_voc;
                    
                    condition.TMR = i_TMR;

                    condition.test_sentence = rand_sent_seq(s);

                    condition.ref_voice = options.test.voice_pairs(i_vp, 1);

                    condition.dir_voice = options.test.voice_pairs(i_vp, 2); 

%                     condition.training1.sentences = rand_train1_seq{i_vp};
%                     condition.training2.sentences = rand_train2_seq{i_vp};

                    condition.training1.sentences = rand_train1_seq{itmr};
                    condition.training2.sentences = rand_train2_seq{itmr};

                    condition.done = 0;

                    condition.visual_feedback = 0;

                    s = s+1; %increment the counter.





                    if ~isfield(test,'conditions')
                        %test.conditions = orderfields(condition);
                        test.conditions = condition;
                    else
                        %test.conditions(end+1) = orderfields(condition);
                        test.conditions(end+1) = condition;
                    end

                end
            end
            
            itmr = itmr+1;
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




