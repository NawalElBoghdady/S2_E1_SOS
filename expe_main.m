function expe_main(options, session)

    %Init GUIs
    %Experiment is defined here!


    results = struct();
    load(options.res_filename); % options, expe, results
    
    test_machine = is_test_machine();
    

%Provide starting instructions
    instr = strrep(options.instructions.start, '\n', sprintf('\n'));
    if ~isempty(instr)
        scrsz = get(0,'ScreenSize');
        if ~test_machine
            left=scrsz(1); bottom=scrsz(2); width=scrsz(3); height=scrsz(4);
        else
            left = -1024; bottom=0; width=1024; height=768;
        end
        scrsz = [left, bottom, width, height];

        msg = struct();
        msgw = 900;
        msgh = 650;
        mr = 60;
        msg.w = figure('Visible', 'off', 'Position', [left+(width-msgw)/2, (height-msgh)/2, msgw, msgh], 'Menubar', 'none', 'Resize', 'off', 'Color', [1 1 1]*.9, 'Name', 'Instructions');

        msg.txt = uicontrol('Style', 'text', 'Position', [mr, 50+mr*2, msgw-mr*2, msgh-(50+mr)-mr*2], 'Fontsize', 18, 'HorizontalAlignment', 'left', 'BackgroundColor', [1 1 1]*.9);

        instr = textwrap(msg.txt, {instr});
        set(msg.txt, 'String', instr);
        msg.bt = uicontrol('Style', 'pushbutton', 'Position', [msgw/2-50, mr, 100, 50], 'String', 'OK', 'Fontsize', 14, 'Callback', 'uiresume');
        set(msg.w, 'Visible', 'on');
        uicontrol(msg.bt);

        uiwait(msg.w);
        close(msg.w);
    end
    
    
    SIMUL = 0;

    beginning_of_session = now();

    rng('shuffle');

    %=============================================================== MAIN LOOP
    
    this_session = find([expe.test.conditions.session] == 1);
    not_done = [expe.test.conditions(this_session).done];
    
    prev_dir_voice = [];
    
    h = initSubjGUI(options);

    drawnow()
    
    [~,name,ext] = fileparts(options.sentence_bank);
    sentences = load(options.sentence_bank,name);
    sentences = sentences.(name);

    while mean(not_done)~=1  % Keep going while there are some conditions in this session left to do

        for vocoder = unique([expe.test.conditions.vocoder])
        
            % Find first condition not done
            i_condition = find([expe.test.conditions.done]==0 & [expe.test.conditions.session] == session...
                & [expe.test.conditions.vocoder] == vocoder, 1);
            fprintf('\n============================ Testing condition %d / %d ==========\n', i_condition, length(expe.test.conditions))
            condition = expe.test.conditions(i_condition);

            if condition.vocoder==0
                fprintf('No vocoder\n\n');
            else
                fprintf('Vocoder: %s\n %s\n %s\n\n', options.vocoder(condition.vocoder).label, options.vocoder(condition.vocoder).parameters.analysis_filters.type);
            end



    %% Training phase:
            if isempty(prev_dir_voice) || prev_dir_voice ~= condition.dir_voice

                %1. Train on target WITHOUT masker:
                tic
                phase = 'training1';

                playTrain(h, options,condition,phase,1,sentences);
                              
                %2. Train on target WITH masker. Give feedback.
                phase = 'training2';
                playTrain(h, options,condition,phase,1,sentences);
                
                toc        
            else
                   
                %3. Begin actual test. Control the experiment flow from another
                %gui 'g':
                phase = 'test';
                instr = strrep(options.instructions.( phase ), '\n', sprintf('\n'));
                h.hide_instruction();
                h.set_instruction(instr);
                h.show_instruction();
                h.set_hstart_text('CONTINUE');
            end
            
            %Continue testing the same voice dir using different sentences.
            h.hide_start();
            
            %Instruct to Listen to the target:
            instr = strrep(options.instructions.listen, '\n', sprintf('\n'));
            h.hide_instruction();
            h.set_instruction(instr);
            h.show_instruction();
            h.disable_start();

            %Play stimulus:
            [target,masker,sentence,fs] = expe_make_stim(options,condition,'training2');
            xOut = (target+masker)*10^(-options.attenuation_dB/20);

            x = audioplayer(xOut,fs,16);
            playblocking(x);
            pause(0.5);

            %Instruct to Repeat the target sentence
            instr = strrep(options.instructions.repeat, '\n', sprintf('\n'));
            h.hide_instruction();
            h.set_instruction(instr);
            h.show_instruction();
            
            
            
            %keep track of the dir voice to know whether you should train
            %subjs if the dir voice changes:
            prev_dir_voice = condition.dir_voice;
            
            
        end
        
        
        
    end
end

function playTrain(h, options,condition,phase,feedback,sentences)
    
    instr = strrep(options.instructions.( phase ), '\n', sprintf('\n'));

    h.set_instruction(instr);
    h.set_hstart_text('CONTINUE');

    movegui(h.f,'center')
    h.make_visible(); 

    uicontrol(h.hstart);
    uiwait(h.f);

    for i = 1:options.training.nsentences
        %h.set_progress(strrep('Training1/2', '_', ' '), sum([expe.( phase ).conditions.done])+1, length([expe.( phase ).conditions.done]));
        h.set_progress(strrep(phase, '_', ' '), i, options.training.nsentences);
        h.set_hstart_text('NEXT');

        %Instruct to Listen to the target:
        instr = strrep(options.instructions.listen, '\n', sprintf('\n'));
        h.hide_instruction();
        h.set_instruction(instr);
        h.show_instruction();
        h.disable_start();

        %Play stimulus:
        [target,masker,sentence,fs] = expe_make_stim(options,condition,phase);
        xOut = (target+masker)*10^(-options.attenuation_dB/20);

        x = audioplayer(xOut,fs,16);
        playblocking(x);
        pause(0.5);

        %Instruct to Repeat the target sentence
        instr = strrep(options.instructions.repeat, '\n', sprintf('\n'));
        h.hide_instruction();
        h.set_instruction(instr);
        h.show_instruction();

        h.enable_start();
        uiwait(h.f);

        if feedback
            %Give feedback by displaying the sentence:
            h.disable_start();
            feedback_sent = sentences{sentence};
            instr = strrep(options.instructions.feedback, '\n', sprintf('\n'));
            h.hide_instruction();
            h.set_instruction([instr feedback_sent]);
            h.show_instruction();
            h.enable_start();
            uiwait(h.f);
            pause(0.5)
        end

        

    end

end