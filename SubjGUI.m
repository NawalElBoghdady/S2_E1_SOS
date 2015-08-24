function SubjGUI
         
    iTrial = 1;
    
    %  Create and then hide the UI as it is being constructed.
    f = figure('Visible', 'off', 'Position', [360,500,450,285], ...
        'Toolbar', 'none', 'Menubar', 'none', 'NumberTitle', 'off');
    hstart = uicontrol('Style','pushbutton',...
        'String','START','Position',[315,180,70,25], ...
        'CallBack', @runNextTrial);
    
    % Assign the a name to appear in the window title.
    f.Name = 'Speech on speech task';
    % Move the window to the center of the screen.
    movegui(f,'center')
    f.Visible = 'on';       

    % VU_zinnen are here!!
    load VU_zinnen_vrouw.mat;
    rndSequence = randperm(length(VU_zinnen_vrouw));
    subID = '01';
    
    function runNextTrial(~,~)
        
        ExperimenterGUI(VU_zinnen_vrouw{rndSequence(iTrial)}, subID, rndSequence(iTrial), iTrial);
        iTrial = iTrial + 1;
        
        if iTrial >1    
            set(hstart, 'String', 'CONTINUE');
        end
    end

    
end