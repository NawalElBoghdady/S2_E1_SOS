function ExperimenterGUI(sentence, SubID, sentenceNum, iTrial)
   
       
    currentDir = pwd;
    screen = monitorSize;
    cd(currentDir);
    

    screen.xCenter = round(screen.width / 2);
    screen.yCenter = round(screen.height / 2);

    minButtonWidth = 20;
    disp.width = minButtonWidth * length(sentence) + 100; % 100 is an arbitrary boundary
    disp.height = 400;
    disp.Left = screen.left + screen.xCenter - (disp.width / 2);

    disp.Up = screen.bottom + screen.yCenter - (disp.height / 2);

    f = figure('Visible','off','Position',[disp.Left, disp.Up, disp.width, disp.height], ...
        'Toolbar', 'none', 'Menubar', 'none', 'NumberTitle', 'off');

    %  Construct the buttons.
    
    buttonName = strsplit(sentence, ' '); % words
    nButtons = length(buttonName);
    buttonheight= 50;
    
    buttonYpos = round(disp.height /2) - round(buttonheight / 2);
    
    for iButton = 1 : nButtons
        buttonWidth = minButtonWidth * length(buttonName{iButton}); % width botton proportional to number of characters in string
        Box.(buttonName{iButton}) = uicontrol('Style','pushbutton','String', buttonName{iButton},...
            'Position',[(disp.width * iButton/(nButtons + 1) - round(buttonWidth / 2)), buttonYpos, buttonWidth, buttonheight],...
            'Callback',@keysCallback, 'Visible', 'On');
    end
    
    buttonWidth = minButtonWidth * length('CONTINUE');

    Box.continue = uicontrol('Style','pushbutton','String', 'CONTINUE',...
            'Position',[(disp.width * iButton/(nButtons + 1) - round(buttonWidth / 2)), buttonYpos - 2*buttonheight, buttonWidth, buttonheight],...
            'Callback',@(hObject,callbackdata) continueCallback(SubID), 'Visible', 'On');
    
    Box.play = uicontrol('Style','pushbutton','String', 'PLAY',...
            'Position',[(disp.width * 1/(nButtons + 1) - round(buttonWidth / 2)), buttonYpos - 2*buttonheight, buttonWidth, buttonheight],...
            'Callback',@playSnd, 'Visible', 'On');    
    
    % Initialize the GUI.
    % Change units to normalized so components resize automatically.
    f.Units = 'normalized';
    NAMES = fieldnames(Box);
    for iButton = 1 : length(NAMES)
        Box.(NAMES{iButton}).Units = 'normalized';
    end

    % Assign the GUI a name to appear in the window title.
    f.Name = 'Speech on Speech Experiment';
    % Move the GUI to the center of the screen.
    movegui(f,'center')
    
    % Make the GUI visible.
    f.Visible = 'on';
    ipush = 1;
    repeatedWords = {''};
    function keysCallback(source, ~)
        repeatedWords{ipush} = source.String;
        ipush = ipush + 1;
        set(Box.(source.String),'enable','off');
    end

    function continueCallback(SubID)
        filename = ['responses_' SubID '.mat'];
        if exist(filename,'file')
            load(filename) % this will overwrite repeated words; need a global counter
            trial(ntrial).ntrial = ntrial +1;
            trial(trial.ntrial).words = repeatedWords;
            trial(trial.ntrial).sentence = sentence;
        else
            ntrial = 1;
            trial.ntrial = ntrial;
            trial.words = repeatedWords;
            trial.sentence = sentence;
        end
        save(filename, 'trial');
        close(f)
    end

    function playSnd(~, ~)
        [y, fs] = audioread([currentDir '/VU_zinnen/Vrouw/' num2str(sentenceNum) '.wav']);
        what2play = audioplayer(y, fs);
        playblocking(what2play);
    end

end

