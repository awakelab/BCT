function [data,dataheaders] = BCT(subjno,savecode,duration,inputkeys,syncsomno,openwindow,win,rect)
% Wong, K. F., Massar, S. A., Chee, M. W., & Lim, J. (2018). 
% Towards an Objective Measure of Mindfulness: 
% Replicating and Extending the Features of the Breath-Counting Task. 
% Mindfulness, 1-9.
% 
% Written by Ken 19 Oct 2016
% Based on Levinson 2014
%
%  output will be saved into a results subfolder from where the BCT script
%  is ran. Subfolder will be created if it doesn't exist
% 
%
%    BCT(subjno,savecode,duration,inputkeys,syncsomno,openwindow,win,rect)
%
%     subjno = subjectnumber as number, not string
%   savecode = string input of identifier i.e. project name
%   duration = duration of task in minutes
%  inputkeys = 3 keys required in cell eg,{'LeftArrow','RightArrow','SPACE'}
%               - key1 - counts 1-8
%               - key2 - count 9
%               - key3 - loss of count
%              If no blank input detected ([]), defaults to leftarrow,
%              right arrow and space for the 3 keys.
%  syncsomno = 1 to sync (3sec count down), 0 for no sync (start after
%              instructions). 
% openwindow = 1 open window, 0 take inputs from win & rect;
%              this should be used either to start the script from scratch
%              (openwindow = 1) or to continue from an already open PTB
%              screen (e.g. continuation from a questionnaire; openwindow =
%              0). If open window call = 0, then the handles for window and
%              resolution needs to be input into BCT
%        win = window handle, not needed if openwindow == 1
%       rect = screen resolution, not needed if openwindow == 1
%
% Updates:
% 20 Oct 2016
%   - Added openwindow option
%
% Updated:
% 13 Jul 2017
%   - Improved script help function
% 
% Updated:
% 21 Jul 2017
%   - Added syncsomno for behavioural and added help
%
% Updated:
% 19 March 2018
%   - Minor changes to help and code optimization
%   - Added data processing before script concludes
%
try
    
    resultsdirectory = [fileparts(mfilename('fullpath')),filesep,'results',filesep];
    if ~exist(resultsdirectory,'dir')
        mkdir(resultsdirectory)
    end   
    
    KbName('UnifyKeyNames');
    duration = duration * 60; %convert duration to seconds.       
    
    data = [];
    dataheaders = {'time';'resp';'count'};
    
    instruction1 = 'In this task,\nwe would like you to be aware of your breath.\n\nPlease be aware of the movement of breath in and out\nin the space below your nose and above your upper lip.\n\nThere''s no need to control the breath.\n\nJust breathe normally.\n\n\nPress the <Right Arrow> to continue.';
    instruction2 = 'At some point,\nyou may notice your attention has wandered\nfrom the breath.\n\nThat''s okay.\nJust gently place it back on the breath.\n\n\nPress the <Right Arrow> to continue';
    instruction3 = 'To help attention stay with the breath,\nyou''ll use a small part of your attention to\nsilently count breaths from 1 to 9, again and again.\n\nAn in and out breath together makes one count.\n\nSay the count softly in your mind so it only gets\na little attention while most of the attention is on feeling the breath.\n\nPlease press the <Left Arrow> using your index finger with breaths 1-8,\nand the <Right Arrow> using your 4th finger with breath 9.\n\nThis means you''ll be pressing a button with each breath.\n\n\nPress the <Right Arrow> to continue';
    instruction4 = 'If you find that you have forgotten the count,\n\njust press the <SPACE> with your Left index finger.\n\nYou can restart the count at 1 with the next breath.\n\nDo not count the breaths using your fingers but only in your head.\n\nPress the <Right Arrow> to continue.';
    if syncsomno
        instruction5 = 'We suggest you sit in an upright, relaxed posture that feels comfortable.\n\nPlease keep your eyes at least partly open\nand resting on the screen during the experiment.\n\nThe task will last about 20 minutes\n\n\nPress <Space> to continue';
    else
        instruction5 = 'We suggest you sit in an upright, relaxed posture that feels comfortable.\n\nPlease keep your eyes at least partly open\nand resting on the screen during the experiment.\n\nThe task will last about 20 minutes\n\n\nPress <Space> start';
    end
    
    %set(0,'Units','Pixels');
    %resolution = get(0,'screensize');
    %windowsize = [800 600];
    %[win,rect] = Screen('OpenWindow',0,[0 0 0],[resolution(3)/2-(windowsize(1)/2) resolution(4)/2-(windowsize(2)/2) resolution(3)/2+(windowsize(1)/2) resolution(4)/2+(windowsize(2)/2) ]);
    
    if openwindow
        AssertOpenGL;
        PsychJavaTrouble;
        Screen('Preference', 'SkipSyncTests', 0);
        Screen('Preference', 'VisualDebuglevel', 3);
        Screen('Preference', 'SuppressAllWarnings', 3);
        [win,rect] = Screen('OpenWindow',0,[0 0 0]);
    end
    
    HideCursor();
    Screen('TextSize',win,40);
    DrawFormattedText(win,'Please wait\nSetting up','center','center',[255 255 255]);
    Screen('Flip',win);
    
    if isempty(inputkeys)
        inputkeys = {'LeftArrow','RightArrow','SPACE'};
    end
    
    keysofinterest = zeros(1,256);
    keysofinterest(KbName('SPACE')) = 1;
    keysofinterest(KbName(inputkeys{1})) = 1; %non 9
    keysofinterest(KbName(inputkeys{2})) = 1; % 9
    keysofinterest(KbName(inputkeys{3})) = 1; % loss
    keysofinterest(KbName('ESCAPE')) = 1;
    
    KbQueueCreate([],keysofinterest);
    KbQueueStart;
    ListenChar(2);
    
    % display instructions1
    DrawFormattedText(win,instruction1,'center','center',[255 255 255]);
    Screen('Flip',win);
    while 1
        [keypress,keycode] = KbQueueCheck;
        if keypress && keycode(KbName('RightArrow'))
            break
        elseif keypress && keycode(KbName('ESCAPE'))
            fprintf('Experimenter Quit\n')
            sca;
            return;
        end
    end
    
    % display instructions1
    DrawFormattedText(win,instruction2,'center','center',[255 255 255]);
    Screen('Flip',win);
    while 1
        [keypress,keycode] = KbQueueCheck;
        if keypress && keycode(KbName('RightArrow'))
            break;
        elseif keypress && keycode(KbName('ESCAPE'))
            fprintf('Experimenter Quit\n')
            sca;
            return;
        end
    end
    
    % display instructions1
    DrawFormattedText(win,instruction3,'center','center',[255 255 255]);
    Screen('Flip',win);
    while 1
        [keypress,keycode] = KbQueueCheck;
        if keypress && keycode(KbName('RightArrow'))
            break;
        elseif keypress && keycode(KbName('ESCAPE'))
            fprintf('Experimenter Quit\n');
            sca;
            return;
        end
    end
    
    % display instructions1
    DrawFormattedText(win,instruction4,'center','center',[255 255 255]);
    Screen('Flip',win);
    while 1
        [keypress,keycode] = KbQueueCheck;
        if keypress && keycode(KbName('RightArrow'))
            break;
        elseif keypress && keycode(KbName('ESCAPE'))
            fprintf('Experimenter Quit\n');
            sca;
            return;
        end
    end
    
    % display instructions1
    DrawFormattedText(win,instruction5,'center','center',[255 255 255]);
    Screen('Flip',win);
    while 1
        [keypress,keycode] = KbQueueCheck;
        if keypress && keycode(KbName('SPACE'))
            break
        elseif keypress && keycode(KbName('ESCAPE'))
            fprintf('Experimenter Quit\n');
            sca;
            return
        end
    end
    
    % EXP start
    
    % Start countdown
    if syncsomno
        DrawFormattedText(win,'Breathe in and press Space to begin\n3 second countdown','center','center',[255 255 255]);
        Screen('Flip',win);
        while 1
            [keypress keycode] = KbQueueCheck;
            if keypress && keycode(KbName('SPACE'));
                break;
            elseif keypress && keycode(KbName('ESCAPE'));
                fprintf('Experimenter Quit\n');
                ListenChar(0);
                KbQueueRelease;
                sca;
                return
            end
        end        
        
        for i = 3:-1:1
            DrawFormattedText(win,sprintf('Exhale\n\n%d',i),'center','center',[255 255 255]);
            ctime = Screen('Flip',win);
            while GetSecs - ctime < 1
            end
        end
    end
    % Start Data Collection
    Screen('Fillrect',win,[0 0 0]);
    starttime = Screen('Flip',win);
    while GetSecs - starttime < duration
        [keypress keycode] = KbQueueCheck;
        if keypress && keycode(KbName(inputkeys{1}))
            data(end+1,1) = keycode(KbName(inputkeys{1}))-starttime;
            data(end,2) = 1;
            if size(data,1) > 1
                if data(end-1,2) == 1
                    data(end,3) = data(end-1,3)+1;
                elseif data(end-1,2) ~= 1
                    data(end,3) = 1;
                end
            elseif size(data,1) == 1
                data(end,3) = 1;
            end
            fprintf('%04.3f | 18    | %d\n',data(end,1),data(end,3));
        elseif keypress && keycode(KbName(inputkeys{2}))
            data(end+1,1) = keycode(KbName(inputkeys{2}))-starttime;
            data(end,2) = 2;
            if size(data,1) > 1
                data(end,3) = data(end-1,3)+1;
            elseif size(data,1) == 1
                data(end,3) = 1;
            end
            fprintf('%04.3f |   9   | %d\n',data(end,1),data(end,3));
        elseif keypress && keycode(KbName(inputkeys{3}))
            data(end+1,1) = keycode(KbName(inputkeys{3}))-starttime;
            data(end,2) = 3;
            if size(data,1) > 1
                data(end,3) = data(end-1,3)+1;
            elseif size(data,1) == 1
                data(end,3) = 1;
            end
            fprintf('%04.3f |     XX | %d\n',data(end,1),data(end,3))
        elseif keypress && keycode(KbName('ESCAPE'))
            error('Experimenter Quit');
        end
    end
        
    DrawFormattedText(win,'End of Task\n\n\nPlease inform the experimenter.','center','center',[255 255 255]);
    Screen('Flip',win);
    while 1
        [keypress,keycode] = KbQueueCheck;
        if keypress && keycode(KbName('ESCAPE'))
            break      
        end
    end
        
    % Process Data
    
    indx_terminate2 = find(data(:,2) == 2);    
    indx_terminate3 = find(data(:,2) ==  3);
    indx_terminate2(:,2) = 2;
    indx_terminate3(:,2) = 3;
    indx_endtrial = sortrows([indx_terminate2; indx_terminate3]);
    
    for i_find = 1:size(indx_endtrial,1)
        % cycle number
        cycle(i_find,1) = i_find;
        % cycle Start keypress #
        if i_find == 1
            cycle(i_find,2) = 1;
        else
            cycle(i_find,2) = indx_endtrial(i_find-1,1)+1;
        end
        % cycle end keypress #
        cycle(i_find,3) = indx_endtrial(i_find,1);
        % number presses in cycle
        cycle(i_find,4) = (cycle(i_find,3) - cycle(i_find,2))+1;
        % Termination Key (2 = count 9) (3 = forget reset);
        cycle(i_find,5) = indx_endtrial(i_find,2);
        % Time Terminate
        cycle(i_find,6) = data(cycle(i_find,3),1);
        % Average keypress length in cycle
        if i_find == 1
        cycle(i_find,7) = (data(cycle(i_find,3),1) - 0)/ cycle(i_find,4);
        else
            cycle(i_find,7) = (data(cycle(i_find,3),1) - data(cycle(i_find,2)-1,1))/ cycle(i_find,4);
        end
    end
    % Examine single resp trials
    % if single trial time < 1 second, Remove it.
    cutoffthreshold_singletrial = 1;
    output.singlesremoved = sum(cycle(:,4)==1 & cycle(:,7) < cutoffthreshold_singletrial);
    output.singlesremoved_detailed = cycle(cycle(:,4)==1 & cycle(:,7) < cutoffthreshold_singletrial,:);
    cycle(cycle(:,4)==1 & cycle(:,7) < cutoffthreshold_singletrial,:) = [];
    
    if output.singlesremoved
        cycle(:,1) = 1:size(cycle,1);
    end
    
    output.totaltrials = size(cycle,1);
    %indx_endtrial(i_find-1,1)+1
    % 1 = acc
    cycle((cycle(:,4) == 9 & cycle(:,5) == 2),8) = 1;
    output.number_acc = sum(cycle(:,8) == 1);
    % 2 = Miscount
    cycle((cycle(:,4) ~= 9 & cycle(:,5) == 2),8) = 2;
    output.number_mis = sum(cycle(:,8) == 2);
    % 3 = Reset
    cycle((cycle(:,5) == 3),8) = 3;
    output.number_res = sum(cycle(:,8) == 3);
    
    if (output.number_acc+output.number_mis+output.number_res)~= output.totaltrials
        %fprintf('cycle numbers don''t tally\n');
        output.manualcheck_required = 1;
    else
        output.manualcheck_required = 0;
    end
    save([resultsdirectory 'BCT_' savecode '_S' sprintf('%03d',subjno) '_' datestr(now,'YYYYmmddhhMM') '_results.mat'],'data','dataheaders','output','cycle');
    ListenChar(0);
    KbQueueRelease;
    if openwindow
        sca;
    end
    ShowCursor();
    
catch breathcounterror
    
    assignin('base','BC_error',breathcounterror);
    fprintf(2,'%s',breathcounterror.message);
    save([resultsdirectory 'BCT_' savecode '_S' sprintf('%03d',subjno) '_crashsave_' datestr(now,'YYYYmmddhhMM') '_results.mat'],'data','dataheaders');
    ListenChar(0);
    KbQueueRelease;
    if openwindow
        sca;
    end
    ShowCursor();
    
end

