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
options.test.nsentences = 4; % Number of test sentences per condition

%% ----------- Stimuli options
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
options.training.voices(1).label = 2^(8/12);

list_size = 13; %nsentences per list

options.training.nsentences = list_size; %number of training sentences per condition.
options.training.voice_pairs = [ones(length(options.training.voices),1), (1:length(options.training.voices))'];

%% --- Define sentence bank for each stimulus type:

%1. Define the lists:
options.sentence_bank = 'VU_zinnen_vrouw.mat';  %Where all sentences in the vrouw database are stored as string.
options.list = {''};
[~,name,~] = fileparts(options.sentence_bank);
sentences = load(options.sentence_bank,name);
sentences = sentences.(name);

for i = 1:list_size:length(sentences)
    if i == 1
        options.list{end} = [i i+12];
    else
        options.list{end+1} = [i i+12];
    end
end

%2. Define the sentence bank for each stimulus type:
options.trainSentences = [options.list{22}(1) options.list{24}(2)];            %training sentences (target)
options.testS1 = [options.list{1}(1) options.list{12}(2)];                     %test sentences Session 1 (target)
options.testS2 = [options.list{12}(1) options.list{20}(2)];                    %test sentences Session 2 (target)
options.masker = [options.list{27}(1) options.list{31}(2)];                    %masker sentences training+test all sessions



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



%% Build Experimental Conditions:

rng('shuffle');


%================================================== Build test block

test = struct();

%1. Define the training sentences:
trainSeq = options.trainSentences(1):options.trainSentences(2);

for session = 1:2
    
    s = 1; %counter for indexing sent_seq
    
    rndSequence = randperm(size(options.test.voice_pairs, 1));


    %2. Randomize Vocoders
    RandVocInd = randperm(length(options.vocoder));
    Vocs = 1:length(options.vocoder); 
    RandVocs = Vocs(RandVocInd);
    
    %3. Randomize the test sentences:
    bank = ['testS' num2str(session)];   
    sent_seq = options.(bank)(1):options.(bank)(2);
   
    rand_sent_seq = datasample(sent_seq,length(sent_seq),'Replace',false); %shuffle the order of the sentences
    
    for i_voc = [0 RandVocs] %0 to indicate the non-vocoded condition 
        
        %3. Randomize TMRs
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
    
            seq = datasample(trainSeq,options.training.nsentences*2,'Replace',false);
            
            for i_vp = rndSequence

                for ir = 1:options.test.nsentences


                    condition = struct();

                    condition.session = session;
                    condition.vocoder = i_voc;
                    
                    condition.TMR = i_TMR;

                    condition.test_sentence = rand_sent_seq(s);

                    condition.ref_voice = options.test.voice_pairs(i_vp, 1);

                    condition.dir_voice = options.test.voice_pairs(i_vp, 2);
                    
                    condition.training1.sentences = [seq(1) seq(2) seq(3)];
                    condition.training2.sentences = [seq(4) seq(5) seq(6)];


                    condition.done = 0;

                    condition.visual_feedback = 0;

                    s = s+1; %increment the counter.


                    if ~isfield(test,'conditions')
                        test.conditions = condition;
                    else
                        test.conditions(end+1) = condition;
                    end

                end
            end
            
        end
    end
end


%====================================== Create the expe structure and save

expe.test = test;

%--
                
if isfield(options, 'res_filename')
    save(options.res_filename, 'options', 'expe');
    
else
    warning('The test file was not saved: no filename provided.');
end




