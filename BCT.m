function [data,dataheaders] = BCT(subjno,savecode,duration,inputkeys,syncsomno,openwindow,win,rect)
% Breath Counting Task
% Based on Levinson 2014
% Written by Ken 19 Oct 2016
%
%    BCT(subjno,savecode,duration,inputkeys,syncsomno,openwindow,win,rect)
%     subjno = subjectnumber
%   savecode = string input of identifier i.e. project name
%   duration = duration of task in minutes
%  inputkeys = 3 keys required in cell eg{'LeftArrow','RightArrow','SPACE'}
%               - key1 - counts 1-8
%               - key2 - count 9
%               - key3 - loss of count
%  syncsomno = 1 to sync (3sec count down), 0 for no sync (start after
%              instructions)
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
        
    save([resultsdirectory 'BCT_' savecode '_S' sprintf('%03d',subjno) '_' datestr(now,'YYYYmmddhhMM') '_results.mat'],'data','dataheaders');
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

