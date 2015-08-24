function [target,fs] = test_createTarget(options,trial,phase)

    %Straight processing happens here!
    
    current_dir = fileparts(mfilename('fullpath'));
    added_path  = {};

    added_path{end+1} = '~/Library/Matlab/auditory_research_tools/vocoder_2015';
    addpath(added_path{end});

    added_path{end+1} = '~/Library/Matlab/auditory_research_tools/STRAIGHTV40_006b';
    addpath(added_path{end});

    added_path{end+1} = '~/Library/Matlab/auditory_research_tools/common_tools';
    addpath(added_path{end});
    
    if strcmp(phase,'test')
        if trial.session == 1
            bank_start = options.testS1(1);
            bank_end = options.testS1(2);
        elseif trial.session == 2
            bank_start = options.testS2(1);
            bank_end = options.testS2(2);
        end
    elseif strcmp(phase,'training1') || strcmp(phase,'training2')
        bank_start = options.trainSentences(1);
        bank_end = options.trainSentences(2);
    end
    
    sentence_bank = bank_start:bank_end;
    sentence = sentence_bank(randperm(length(sentence_bank),1)); %randomly choose a target sentence from the test bank
    %NOTE: This does not guarantee that you don't choose the same sentence
    %more than once in a session!!!! Fix later!!
    
    f0 = options.test.voices(trial.dir_voice).f0;
    ser = options.test.voices(trial.dir_voice).ser;
    
    [y,fs] = straight_process(sentence, f0, ser, options, trial.session);
    
    if trial.vocoder > 0
            
        [x, fs] = vocode(y, fs, options.vocoder(trial.vocoder).parameters);

        x = x(:);

        
        %This prevents the wavwrite from clipping the data
        
        m = max(abs(min(x)),max(x)) + 0.001;
        x = x./m;

        switch options.ear
            case 'right'
                x  = [zeros(size(x)), x];
            case 'left'
                x = [x, zeros(size(x))];
            case 'both'
                x = repmat(x, 1, 2);
            otherwise
                error(sprintf('options.ear="%s" is not implemented', options.ear));
        end
        
        target = x;
    else
        target = y;
    end
                                                            
    %------------------------------------------
    %% Clean up the path

    for i=1:length(added_path)
        rmpath(added_path{i});
    end
    

end

function [y, fs] = straight_process(sentence, t_f0, ser, options, session)

    wavIn = fullfile(options.sound_path, [num2str(sentence), '.wav']);
    wavOut = make_fname(session, wavIn, t_f0, ser, options.tmp_path);

%     if ~exist('audioread')
%         audioread = @wavread;
%     end
% 
%     if ~exist('audiowrite')
%         audiowrite = @(fname, x, fs) wavwrite(x,fs,fname);
%     end

    if ~exist(wavOut, 'file')

%         if ~is_test_machine()
%             straight_path = '~/Library/Matlab/STRAIGHTV40_006b';
%         else
%             straight_path = '~/Library/Matlab/STRAIGHTV40_006b';
%         end
%         addpath(straight_path);

        mat = strrep(wavIn, '.wav','.straight.mat');

        if exist(mat, 'file')
            load(mat);
        else
            [x, fs] = audioread(wavIn);
            [f0, ap] = exstraightsource(x, fs);
            
            sp = exstraightspec(x, f0, fs);
            x_rms = rms(x);

            save(mat, 'fs', 'f0', 'sp', 'ap', 'x_rms');
        end

        mf0 = exp(mean(log(f0(f0~=0))));

        f0(f0~=0) = f0(f0~=0) / mf0 * t_f0;

        p.frequencyAxisMappingTable = ser;
        y = exstraightsynth(f0, sp, ap, fs, p);

        y = y/rms(y)*x_rms;
        if max(abs(y))>1
            warning('Output was renormalized for "%s".', wavOut);
            y = 0.98*y/max(abs(y));
        end 

        audiowrite(wavOut, y, fs);

        %rmpath(straight_path);
    else



        [y, fs] = audioread(wavOut);
        %[y, fs] = wavread(wavOut);
    end
end

function fname = make_fname(session, wav, f0, ser, destPath)

%make_fname(session, wavIn, t_f0, ser, options.tmp_path);
     [~, name, ext] = fileparts(wav);
    
    fname = sprintf('%s_%s_GPR%d_SER%.2f', ['S' num2str(session)], name, floor(f0), ser);
   
    fname = fullfile(destPath, [fname, ext]);
end
