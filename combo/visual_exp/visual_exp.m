function []=visual_exp()
clear;
clc;
sca;
 p = gcp();

 Screen('Preference', 'SkipSyncTests', 2);
 
try
    % �ռ�����ʵ���ߵ���Ϣ
    prompt = {'Subject Number','Gender[1 = m, 2 = f]','Age','Handeness[1 = left, 2 = right]','trail�Ĵ���'};
    title = 'Exp infor'; 
    definput = {'','','','',''};
    
    
    % ʹ�� inputdlg() �����ݴ洢�ڴ����ľ�����
    % �Ի���ĸ߶�Ϊһ���ַ�������Ϊ50���ַ�,�˴�ʵ��trialΪ5�Ρ�
    subinfo = inputdlg(prompt,title,[1, 50],definput);
    num = str2double(char(subinfo(5)));
    % �����洢���ݵľ���
    arrow_data = cell(num,9);
    arrow_data(1:num, 1:4) = repmat(subinfo(1:4)', num, 1);
    
    HideCursor;
    
    % ʵ��׼������
    
    % �򿪴���
    [w, wrect] = Screen('OpenWindow', 0, [0,0,0]);
    
    % ��ȡ��ʾ����Ļ�����ĵ��λ��
    [x_center, y_center] = RectCenter(wrect);
    
    % ��ȡ��ǰ��ʾ��ÿˢ��һ֡���������
    ifi = Screen('GetFlipInterval', w);
    
    % Text font and text color
    %Screen('TextFont', w, 'Simhei');
    %Screen('TextSize', w, 65);
    
    % ���ð���
    KbName('UnifyKeyNames');
    left_key = KbName('LeftArrow');
    right_key = KbName('RightArrow');
    up_key = KbName('UpArrow');
    down_key = KbName('DownArrow');
    % space_key = KbName('space');
    esc_key = KbName('escape');
    
    % ׼��ʵ�����
    
    % ͼƬ����
    img = zeros(num, 1);
    for i = 1:num
        arrow_data{i, 5} = unifrnd(0.5,1.2); % ע�ӵ�ʱ��
        if unidrnd(4) == 1 
            arrow_data{i, 6} = '��';
            img(i,1) = 1;
            
        elseif unidrnd(4) == 2
            arrow_data{i, 6} = '��';
            img(i,1) = 2;
            
        elseif unidrnd(4) == 3
            arrow_data{i, 6} = '��';
            img(i,1) = 3;
            
        else 
            arrow_data{i, 6} = '��';
            img(i,1) = 4;
            
        end
    end

    
    % ����ָ����
    exp_instruction = Screen('MakeTexture', w, imread('visual_exp\pic\visual_instruction.tif'));
    exp_end = Screen('MakeTexture', w, imread('visual_exp\pic\exp_end.tif'));
   
    Screen('DrawTexture', w, exp_instruction, []);
    Screen('Flip', w);
    KbStrokeWait; % ���Ķ���ָ��������������
    
    % ����trail����,�Ƚ���5��trail
    for trial = 1:num
        % ����ע�ӵ�: 500~1200ms
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
        
        % ͨ��GetSecs��ȡһ��ʱ���������t0����Ϊ�̼����ֵ���ʼʱ���
        t0 = GetSecs; % �Դ̼�����֮�󾭹���ʱ��
        % ʹ�ű��ڳ��ִ̼����500ms�ڣ���������whileѭ���ڵ����     
        while GetSecs - t0 < 0.5
            % ��鱻�԰��µİ���
            [keyisdown, secs, keycode] = KbCheck;
            %���������Esc������ֱ�ӽ����ű�
            if keycode(esc_key)
                sca;
                return
            % ����ǰ��������İ������򽫰��������ƺͷ�Ӧʱ�䣨GetSecs - t0����¼�����ݾ����С�    
            elseif keyisdown 
                arrow_data{trial, 7} = KbName(keycode); % resp
                arrow_data{trial, 8} = GetSecs - t0; % rt
                % acc
                % �������Ϊ������Ҵ̼�Ϊ���ͷ�����߰���Ϊ�ҷ�����Ҵ̼�Ϊ�Ҽ�ͷ������Դε���ȷ�ʼ�Ϊ1����֮��Ϊ0
                if keycode(left_key) && arrow_data{trial, 6} == '��'
                    arrow_data{trial, 9} = 1; % acc=1
                elseif keycode(up_key) && arrow_data{trial, 6} == '��'
                    arrow_data{trial, 9} = 1; % acc=1
                elseif keycode(right_key) && arrow_data{trial, 6} == '��'
                    arrow_data{trial, 9} = 1; % acc=1
                elseif keycode(down_key) && arrow_data{trial, 6} == '��'
                    arrow_data{trial, 9} = 1; % acc=1
                else
                    arrow_data{trial, 9} = 0; % acc=0
                end
                break % break the loop
             % û�а�����Ӧ����ʱ���ǽ���Ӧ��������Ӧʱ����ȷ�ʶ���ΪNA
             else
                arrow_data{trial, 7} = 'NA'; % resp
                arrow_data{trial, 8} = 'NA'; % rt
                arrow_data{trial, 9} = 'NA'; % acc
            end

        end
    
        % ���ֿ���
        % Interval: 300ms
            Screen('Flip', w);
            WaitSecs(0.3);       
    end
    
    % ���ֽ����1s���˳�
    for i = 1:round(2 / ifi)
        Screen('DrawTexture', w, exp_end, []);
        Screen('Flip', w);
    end
    
    %��������
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
% %         data_table(trials,1).Test = probe{trials,1};%��ǰ��Ļ��ʾ��ֵ
% % 
% %         data_table(trials+n_num,1).nbTest = probe{trials,1}; %��Ҫ��Ӧ��ֵ
%     end
    
    sca;
%     �ɹ����б�־
    disp('Succeed!');
%     ���������ļ�
%     header = {'SubjectNumber', 'Gender', 'Age', 'Handedness',...
%         'DotsTime', 'Arrow', 'Resp', 'RT', 'ACC'};
%     data_table = cell2table(arrow_data, 'VariableNames', header);
%     
% %     ����csv�ļ�
%     exp_data = strcat('visual_exp\data\', 'arrow_exp_', char(arrow_data{1,1}), '_', date, '.csv');
%     writetable(data_table, exp_data);

% �첽���ô洢����
    f = parfeval(p,@saveFile,1,arrow_data,1,num);
    disp(fetchOutputs(f));   
    
    
    
catch
    ShowCursor;
    sca;
    psychrethrow(psychlasterror);
end
end