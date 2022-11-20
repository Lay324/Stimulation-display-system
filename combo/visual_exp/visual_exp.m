function []=visual_exp()
clear;
clc;
sca;
 p = gcp();

 Screen('Preference', 'SkipSyncTests', 2);
 
try
    % 收集关于实验者的信息
    prompt = {'Subject Number','Gender[1 = m, 2 = f]','Age','Handeness[1 = left, 2 = right]','trail的次数'};
    title = 'Exp infor'; 
    definput = {'','','','',''};
    
    
    % 使用 inputdlg() 将数据存储在创建的矩阵中
    % 对话框的高度为一个字符，长度为50个字符,此次实验trial为5次。
    subinfo = inputdlg(prompt,title,[1, 50],definput);
    num = str2double(char(subinfo(5)));
    % 创建存储数据的矩阵
    arrow_data = cell(num,9);
    arrow_data(1:num, 1:4) = repmat(subinfo(1:4)', num, 1);
    
    HideCursor;
    
    % 实验准备工作
    
    % 打开窗口
    [w, wrect] = Screen('OpenWindow', 0, [0,0,0]);
    
    % 获取显示器屏幕的中心点的位置
    [x_center, y_center] = RectCenter(wrect);
    
    % 获取当前显示器每刷新一帧所需的秒数
    ifi = Screen('GetFlipInterval', w);
    
    % Text font and text color
    %Screen('TextFont', w, 'Simhei');
    %Screen('TextSize', w, 65);
    
    % 设置按键
    KbName('UnifyKeyNames');
    left_key = KbName('LeftArrow');
    right_key = KbName('RightArrow');
    up_key = KbName('UpArrow');
    down_key = KbName('DownArrow');
    % space_key = KbName('space');
    esc_key = KbName('escape');
    
    % 准备实验材料
    
    % 图片材料
    img = zeros(num, 1);
    for i = 1:num
        arrow_data{i, 5} = unifrnd(0.5,1.2); % 注视点时间
        if unidrnd(4) == 1 
            arrow_data{i, 6} = '←';
            img(i,1) = 1;
            
        elseif unidrnd(4) == 2
            arrow_data{i, 6} = '↑';
            img(i,1) = 2;
            
        elseif unidrnd(4) == 3
            arrow_data{i, 6} = '→';
            img(i,1) = 3;
            
        else 
            arrow_data{i, 6} = '↓';
            img(i,1) = 4;
            
        end
    end

    
    % 呈现指导语
    exp_instruction = Screen('MakeTexture', w, imread('visual_exp\pic\visual_instruction.tif'));
    exp_end = Screen('MakeTexture', w, imread('visual_exp\pic\exp_end.tif'));
   
    Screen('DrawTexture', w, exp_instruction, []);
    Screen('Flip', w);
    KbStrokeWait; % 在阅读完指导语后按任意键继续
    
    % 构建trail内容,先进行5个trail
    for trial = 1:num
        % 呈现注视点: 500~1200ms
        for i = 1:round(cell2mat(arrow_data(trial, 5)) / ifi)
            Screen('DrawDots', w, [x_center; y_center], 30, [255,255,255], [], 1);
            Screen('Flip', w);
        end
        
        % Stimulus: 500ms
        if img(trial,1) == 1
            left_image = Screen('MakeTexture',w,imread('visual_exp\pic\left.tif'));
            Screen('DrawTexture', w, left_image, []);
            Screen('Flip', w);
        elseif img(trial,1) == 2
            up_image = Screen('MakeTexture',w,imread('visual_exp\pic\up.tif'));
            Screen('DrawTexture', w, up_image, []);
            Screen('Flip', w);
        elseif img(trial,1) == 3
            right_image = Screen('MakeTexture',w,imread('visual_exp\pic\right.tif'));
            Screen('DrawTexture', w, right_image, []);
            Screen('Flip', w);
        else 
            down_image = Screen('MakeTexture',w,imread('visual_exp\pic\down.tif'));
            Screen('DrawTexture', w, down_image, []);
            Screen('Flip', w);
        end
        
        % 通过GetSecs获取一个时间戳，赋给t0，作为刺激呈现的起始时间点
        t0 = GetSecs; % 自刺激呈现之后经过的时间
        % 使脚本在呈现刺激后的500ms内，反复运行while循环内的语句     
        while GetSecs - t0 < 0.5
            % 检查被试按下的按键
            [keyisdown, secs, keycode] = KbCheck;
            %如果按的是Esc键，则直接结束脚本
            if keycode(esc_key)
                sca;
                return
            % 如果是按了其它的按键，则将按键的名称和反应时间（GetSecs - t0）记录到数据矩阵中。    
            elseif keyisdown 
                arrow_data{trial, 7} = KbName(keycode); % resp
                arrow_data{trial, 8} = GetSecs - t0; % rt
                % acc
                % 如果按键为左方向键且刺激为左箭头，或者按键为右方向键且刺激为右箭头，则该试次的正确率记为1，反之记为0
                if keycode(left_key) && arrow_data{trial, 6} == '←'
                    arrow_data{trial, 9} = 1; % acc=1
                elseif keycode(up_key) && arrow_data{trial, 6} == '↑'
                    arrow_data{trial, 9} = 1; % acc=1
                elseif keycode(right_key) && arrow_data{trial, 6} == '→'
                    arrow_data{trial, 9} = 1; % acc=1
                elseif keycode(down_key) && arrow_data{trial, 6} == '↓'
                    arrow_data{trial, 9} = 1; % acc=1
                else
                    arrow_data{trial, 9} = 0; % acc=0
                end
                break % break the loop
             % 没有按键反应，此时我们将反应按键、反应时和正确率都记为NA
             else
                arrow_data{trial, 7} = 'NA'; % resp
                arrow_data{trial, 8} = 'NA'; % rt
                arrow_data{trial, 9} = 'NA'; % acc
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
    
    %数据整理
%     for trial = 1:num
%         %arrow_data(trials,1).SubNo = str2double(char(subinfo(1)));
%         if str2double(arrow_data{trial, 2}) == 1
%             arrow_data{trial,2} = 'Male';
%         else
%             arrow_data{trial, 2} = 'Female';
%         end
%         %arrow_data(trials,1).Age = str2double(char(subinfo(3)));
%         if  str2double(arrow_data{trial, 4}) == 1
%             arrow_data{trial, 4} = 'Right';
%         else
%             arrow_data{trial, 4} = 'Left';
%         end
% 
% %         data_table(trials,1).Test = probe{trials,1};%当前屏幕显示的值
% % 
% %         data_table(trials+n_num,1).nbTest = probe{trials,1}; %需要反应的值
%     end
    
    sca;
%     成功运行标志
    disp('Succeed!');
%     保存数据文件
%     header = {'SubjectNumber', 'Gender', 'Age', 'Handedness',...
%         'DotsTime', 'Arrow', 'Resp', 'RT', 'ACC'};
%     data_table = cell2table(arrow_data, 'VariableNames', header);
%     
% %     创建csv文件
%     exp_data = strcat('visual_exp\data\', 'arrow_exp_', char(arrow_data{1,1}), '_', date, '.csv');
%     writetable(data_table, exp_data);

% 异步调用存储数据
    f = parfeval(p,@saveFile,1,arrow_data,1,num);
    disp(fetchOutputs(f));   
    
    
    
catch
    ShowCursor;
    sca;
    psychrethrow(psychlasterror);
end
end