function []=change()

clear;
clc;
sca;
%p = gcp();

% Screen('Preference', 'SkipSyncTests', 2);
% 本实验判断第N个刺激和当前刺激是否一致，如果一致请按T键，如果不一致请按F键

try
    % 创建存储数据的矩阵
    % change_data = cell(10,9);
    
    % 收集关于实验者的信息
    prompt = {'Subject Number','Gender[1 = m, 2 = f]','Age','Handeness[1 = left, 2 = right]','n的数值'};
    dlg_title = 'Exp infor'; 
    %num_line = 1;
    def_answer = {'1','1','18','1','2'};
    subinfo = inputdlg(prompt,dlg_title,[1, 50],def_answer);
    n_num = str2double(char(subinfo(5)));
    
    
    %刺激
    fix = '+';
    probe = {'A',1;'B',2};
    probe = repmat(probe,5,1);
    randIndex = randperm(length(probe));
    probe= probe(randIndex,:);

    %时间
    dura.fix = 0.5;
    dura.probe = 2;
    dura.feed = 0.5;

    %按键
    KbName('UnifyKeyNames');
    key.escape = KbName('escape');
    key.t = KbName('t');
    key.f = KbName('f');

    %颜色
    rgb.bk = [0 0 0];
    rgb.font = [255 255 255];
    %窗口
    AssertOpenGL;
    Screen('Preference', 'SkipSyncTests', 1);
    screens = Screen('Screens');
    maxscreens = max(screens);
    [win,~] = Screen('OpenWindow',maxscreens,rgb.bk);
    
    HideCursor;
    
    slack = Screen('GetFlipInterval',win)/2;
    
    % 呈现指导语
    %指导与结束语
    exp_instruction = Screen('MakeTexture', win, imread('change_exp\pic\n-back_instruction.tif'));
    exp_end = Screen('MakeTexture', win, imread('change_exp\pic\exp_end.tif'));
    Screen('DrawTexture', win, exp_instruction, []);
    Screen('Flip', win);
    KbStrokeWait; % 在阅读完指导语后按任意键继续
    
    probe = repmat(probe,4,1);
    randIndex = randperm(length(probe));
    probe= probe(randIndex,:);

    data_table = repmat(struct('SubNo',1),length(probe),1);%预分配内存 提高运行速率
    ab = n_num;

    while ab ~= 0
    for trials = 1:n_num
        %注视点
        Screen('TextSize',win,28);
        Screen('TextFont',win,'Times New Roman');
        DrawFormattedText(win,fix,'center','center',rgb.font);
        tFix = Screen('Flip',win);

        %刺激
        Screen('TextSize',win,100);
        Screen('TextFont',win,'Times New Roman');
        DrawFormattedText(win,double(probe{trials,1}),'center','center',rgb.font);
        tFix = Screen('Flip',win,tFix+dura.fix-slack);

        %缓冲
        Screen('TextSize',win,28);
        Screen('TextFont',win,'Times New Roman');
        DrawFormattedText(win,fix,'center','center',rgb.font);
        Screen('Flip',win,tFix+dura.probe-slack);
        WaitSecs(dura.feed);
    end
    ab = 0;
    end

    for trials = (n_num+1):length(probe)

        %注视点
        Screen('TextSize',win,28);
        Screen('TextFont',win,'Times New Roman');
        DrawFormattedText(win,fix,'center','center',rgb.font);
        tFix = Screen('Flip',win);

        %刺激
        Screen('TextSize',win,100);
        Screen('TextFont',win,'Times New Roman');
        DrawFormattedText(win,double(probe{trials,1}),'center','center',rgb.font);
        tFix = Screen('Flip',win,tFix+dura.fix-slack);

        while true %按键判断
           [~,secs,KbCode] = KbCheck;
           if  KbCode(key.t)
               resp = 1;
               rt = secs-tFix;
               break;
           elseif KbCode(key.f)
               resp = 2;
               rt = secs-tFix;
               break;
           elseif KbCode(key.escape)
               Screen('CloseAll');
               break;
           end;
           if GetSecs-tFix >= dura.probe
               rt = 'O.T';
               resp = 3;
               break;
           end;
        end
        %反应数据收集

        data_table(trials,1).RT = rt;
        if n_num == 0
            if resp == 3
                data_table(trials,1).ACC = 0;
            elseif (resp ==1 && probe{trials-n_num,2} == 1) ||...
                    (resp == 2 && probe{trials-n_num,2} == 2)
                data_table(trials,1).ACC = 1;
            else 
                data_table(trials,1).ACC = 0;
            end
        else
            if resp == 3
                data_table(trials,1).ACC = 0;
            elseif (resp ==1 && (probe{trials,2} == probe{trials-n_num,2})) ||...
                (resp == 2 && (probe{trials,2} ~= probe{trials-n_num,2}))
                data_table(trials,1).ACC = 1;
            else 
                data_table(trials,1).ACC = 0;
            end
        end

        Screen('TextSize',win,28);
        Screen('TextFont',win,'Times New Roman');
        DrawFormattedText(win,fix,'center','center',rgb.font);
        Screen('Flip',win);
        WaitSecs(dura.feed);

    end

    % 呈现结束语，1s后退出
    for i = 1:round(2 / Screen('GetFlipInterval',win))
        Screen('DrawTexture', win, exp_end, []);
        Screen('Flip', win);
    end
    
    sca;
    %数据整理
    for trials = 1:length(probe)
        data_table(trials,1).SubNo = str2double(char(subinfo(1)));
        if str2double(char(subinfo(2))) == 1
            data_table(trials,1).Gender = 'Male';
        else
            data_table(trials,1).Gender = 'Female';
        end
        data_table(trials,1).Age = str2double(char(subinfo(3)));
        if  str2double(char(subinfo(4))) == 1
            data_table(trials,1).Handedness = 'Right';
        else
            data_table(trials,1).Handedness = 'Left';
        end

        data_table(trials,1).Test = probe{trials,1};%当前屏幕显示的值

        data_table(trials+n_num,1).nbTest = probe{trials,1}; %需要反应的值
    end

    columheader ={'SubNo','Gender','Age','Handedness','Test','nbTest','ACC','RT'};
    data_table = orderfields(data_table,columheader);
    ret = [columheader;(struct2cell(data_table))'];
    ret = ret(1:(trials+1),:); %修饰多余数据
    xlswrite(['change_exp\data\','Nback_',char(subinfo(1)),'_',date,'.xls'],ret);
    
    % 成功运行标志
    disp('Succeed!');
%     f = parfeval(p,@saveFile,1,data_table,3);
%     disp(fetchOutputs(f));
    
catch
    ShowCursor; % 程序出错，显示鼠标指针
    sca;
    psychrethrow(psychlasterror); % 显示错误代码位置
end
end