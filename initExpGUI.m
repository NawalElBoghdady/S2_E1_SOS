function h = initExpGUI(expe,options)
   
       
%     currentDir = pwd;
%     cd(currentDir);

    h = struct();
    
    scrsz = get(0,'ScreenSize');
    
    fntsze = 20;
    
    if ~is_test_machine
        left = scrsz(1); bottom = scrsz(2); width = scrsz(3); height = scrsz(4);
    else
        left = -1024; bottom=0; width=1024; height=768;
    end
    
    scrsz = [left, bottom, width, height];
    n_rows = 1; 
    n_cols = 3; 
    grid_sz = [n_cols, n_rows]*300;
    
    screen.xCenter = round(scrsz(3) / 2);
    screen.yCenter = round(scrsz(4) / 2);

%     disp.width = minButtonWidth * length(sentence) + 100; % 100 is an arbitrary boundary
%     disp.height = 400;
%     disp.Left = scrsz(1) + screen.xCenter - (disp.width / 2);
% 
%     disp.Up = scrsz(2) + screen.yCenter - (disp.height / 2);

    h.f = figure('Visible', 'off','Units','normalized', 'Position', scrsz, ...
        'Toolbar', 'none', 'Menubar', 'none', 'NumberTitle', 'off');

    %  Construct the buttons.
    
    h.init_buttons = @(s) init_buttons(h,s);

    h.init_continue = @(s,i) init_continue(h,s,i);
    
    
    Box.play = uicontrol('Style','pushbutton','String', 'PLAY',...
            'Position',[width/2-grid_sz(1)/50, height/2-grid_sz(2), grid_sz(2), 100],...
            'Callback',@playSnd, 'Visible', 'On');    
    
    

    % Assign the GUI a name to appear in the window title.
    h.f.Name = 'Speech on Speech: Experimenter GUI';
    
    
    % Make the GUI visible.
    h.f.Visible = 'on';
    ipush = 1;
    repeatedWords = {''};
    
    function init_buttons(h,sentence)
        
        minButtonWidth = 20;
        buttonName = strsplit(sentence, ' '); % words
        nButtons = length(buttonName);
        buttonheight= 50;
        dispwidth = minButtonWidth * length(sentence) + 100; % 100 is an arbitrary boundary
        dispheight = 400;
        buttonYpos = round(dispheight /2) - round(buttonheight / 2);

        for iButton = 1 : nButtons
            buttonWidth = minButtonWidth * length(buttonName{iButton}); % width button proportional to number of characters in string
            Box.(buttonName{iButton}) = uicontrol('Style','pushbutton','Units','pixels','String', buttonName{iButton},...
                'Position',[(dispwidth * iButton/(nButtons + 1) - round(buttonWidth / 2)), buttonYpos, buttonWidth, buttonheight],...
                'Callback',@keysCallback, 'Visible', 'On');
        end 
        
    end

    function init_continue(h,sentence,i_condition)
        Box.continue = uicontrol('Style','pushbutton','String', 'CONTINUE',...
            'Position',[width/2-grid_sz(1)/2, height/2-grid_sz(2), grid_sz(2), 100],...
            'Callback',@(hObject,callbackdata) continueCallback(expe,options,sentence,i_condition), 'Visible', 'On');
    end
    
    function keysCallback(source, h)
        repeatedWords{ipush} = source.String;
        ipush = ipush + 1;
        set(Box.(source.String),'enable','off');
    end

    function continueCallback(expe,options,sentence,i_condition)
        
        %check if 'results' field exists:
        filename = options.res_filename;
        vars = whos('-file',filename);
        results_exist = ismember('results', {vars.name});
            
        if results_exist
            load(filename,'results') % this will overwrite repeated words; FIX!!!
            results(i_condition).words = repeatedWords;
            results(i_condition).sentence = sentence;
            results(i_condition).nwords_correct = length(repeatedWords);
            
        else
            results.words = repeatedWords;
            results.sentence = sentence;
            results.nwords_correct = length(repeatedWords);
        end
        save(filename,'expe','options','results');
        close(h.f)
    end

    function playSnd(~, ~)
        [y, fs] = audioread([currentDir '/VU_zinnen/Vrouw/' num2str(sentenceNum) '.wav']);
        what2play = audioplayer(y, fs);
        playblocking(what2play);
    end

end

