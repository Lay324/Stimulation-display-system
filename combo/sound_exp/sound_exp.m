function []=sound_exp()

clear;
clc;
sca;
p = gcp();

InitializePsychSound;
Screen('Preference', 'SkipSyncTests', 2);

try
    
    % trial = 10;
    
    % 收集被试者信息
    prompt = {'Subject Number','Gender[1 = m, 2 = f]','Age','Handeness[1 = left, 2 = right]','trail的次数'};
    title = 'Exp infor'; 
    definput = {'','','','',''};
    
    subinfo = inputdlg(prompt,title,[1, 50],definput);
    num = str2double(char(subinfo(5)));
    sound_data = cell(num,9);
    sound_data(1:num, 1:4) = repmat(subinfo(1:4)', num, 1);
    
    HideCursor;
    
    % 实验准备工作
    
    % 打开窗口
    [w, wrect] = Screen('OpenWindow', 0, [0, 0, 0]);
    
    % 获取显示器屏幕的中心点的位置
    [x_center, y_center] = RectCenter(wrect);
    
     % 获取当前显示器每刷新一帧所需的秒数
    numSecs = 1;
    waitframes = 1;
    ifi = Screen('GetFlipInterval', w);
    %frame = round(numSecs / ifi);  % 刺激呈现的帧数
    slack = ifi/2;
    vbl = Screen('Flip',w );
    
    % Text font and text color
    %Screen('TextFont', w, 'Simhei');
    %Screen('TextSize', w, 65);
    
    % 设置按键
    KbName('UnifyKeyNames');          
    space_key = KbName('Space');
    esc_key = KbName('Escape');
    
    % 准备实验材料
    for i = 1:num
        sound_data{i, 5} = unifrnd(0.5,1.2); % 注视点时间   
        sound_data{i, 6} = 'Beep';
    end
    
    % 呈现指导语
    exp_instruction = Screen('MakeTexture', w, imread('sound_exp\pic\sound_instruction.tif'));
    exp_end = Screen('MakeTexture', w, imread('sound_exp\pic\exp_end.tif'));
    
    Screen('DrawTexture', w, exp_instruction, []);
    Screen('Flip', w);
    KbStrokeWait; % 在阅读完指导语后按任意键继续
    
    % 呈现刺激
    for trial = 1 : num
        % 呈现注视点
        for i = 1:round(cell2mat(sound_data(trial, 5)) / ifi)
            Screen('DrawDots', w, [x_center; y_center], 30, [255,255,255], [], 1);
            Screen('Flip', w);
        end
        
        % 呈现刺激
        freq = 48000; % 音频的采样频率
        % 设置音频
        pahandle = PsychPortAudio('Open', [], 1, 1, freq, 2);
        PsychPortAudio('Volume', pahandle, 0.5); %音量50%
        [myBeep, samplingRate] = MakeBeep(500, 0.5, freq); %制作“哔”
        PsychPortAudio('FillBuffer', pahandle, [myBeep; myBeep]); %将音频转换为立体声
        startTime = PsychPortAudio('Start', pahandle, 1, 0, 1);
        
        [startTime, endPositionSecs, xruns, estStopTime] = PsychPortAudio('Stop', pahandle, 1, 1);
        %sound_data{i,7} = estStopTime - startTime;  % PsychPortAudio timing
        WaitSecs(0.1);
        
        [keyisdown, secs, keycode] = KbCheck;
        
        vbl = Screen('Flip', w, vbl+(1 - 0.5)*ifi);
        
        % 使脚本在呈现刺激后的500ms内，反复运行while循环内的语句  
        t0 = GetSecs;
        while GetSecs - t0 < 1
            % 检查被试按下的按键
            [keyisdown, secs, keycode] = KbCheck;
            %如果按的是Esc键，则直接结束脚本
            if keycode(esc_key)
                sca;
                return
            elseif keyisdown
                sound_data{trial, 7} = KbName(keycode); % resp
                sound_data{trial, 8} = secs - startTime; % rt
                sound_data{trial, 9} = 1; % acc=1
                 break % break the loop
            else
                sound_data{trial, 7} = 'NA'; % resp
                sound_data{trial, 8} = 'NA'; % rt
                sound_data{trial, 9} = 'NA'; % acc
                break
            end
        end    
        
         % 呈现空屏
        % Interval: 300ms
            Screen('Flip', w);
            WaitSecs(0.3);      
        
    end  
    
    % 呈现结束语，1s后退出
    for i = 1:round(2 / ifi)
        Screen('DrawTexture', w, exp_end, []);
        Screen('Flip', w);
    end
    
    sca;

    % PsychPortAudio的关闭
    PsychPortAudio('Close', pahandle);
     
    % 保存数据文件
   % header = {'SubjectNumber', 'Gender', 'Age', 'Handedness',...
    %    'DotsTime', 'ExpIterm', 'Resp', 'RT', 'ACC'};
    %data_table = cell2table(sound_data, 'VariableNames', header);
    
    % 创建csv文件
    %exp_data = strcat('sound_exp\data\', 'sound_exp_', char(sound_data{1,1}), '_', date, '.csv');
    %writetable(data_table, exp_data);
    
    % 成功运行标志
    disp('Succeed!');
    f = parfeval(p,@saveFile,1,sound_data,2,num);
    disp(fetchOutputs(f));
    
catch
    ShowCursor; % 程序出错，显示鼠标指针
    sca;
    psychrethrow(psychlasterror); % 显示错误代码位置
end

end