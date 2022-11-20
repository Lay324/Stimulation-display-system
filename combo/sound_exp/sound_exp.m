function []=sound_exp()

clear;
clc;
sca;
p = gcp();

InitializePsychSound;
Screen('Preference', 'SkipSyncTests', 2);

try
    
    % trial = 10;
    
    % �ռ���������Ϣ
    prompt = {'Subject Number','Gender[1 = m, 2 = f]','Age','Handeness[1 = left, 2 = right]','trail�Ĵ���'};
    title = 'Exp infor'; 
    definput = {'','','','',''};
    
    subinfo = inputdlg(prompt,title,[1, 50],definput);
    num = str2double(char(subinfo(5)));
    sound_data = cell(num,9);
    sound_data(1:num, 1:4) = repmat(subinfo(1:4)', num, 1);
    
    HideCursor;
    
    % ʵ��׼������
    
    % �򿪴���
    [w, wrect] = Screen('OpenWindow', 0, [0, 0, 0]);
    
    % ��ȡ��ʾ����Ļ�����ĵ��λ��
    [x_center, y_center] = RectCenter(wrect);
    
     % ��ȡ��ǰ��ʾ��ÿˢ��һ֡���������
    numSecs = 1;
    waitframes = 1;
    ifi = Screen('GetFlipInterval', w);
    %frame = round(numSecs / ifi);  % �̼����ֵ�֡��
    slack = ifi/2;
    vbl = Screen('Flip',w );
    
    % Text font and text color
    %Screen('TextFont', w, 'Simhei');
    %Screen('TextSize', w, 65);
    
    % ���ð���
    KbName('UnifyKeyNames');          
    space_key = KbName('Space');
    esc_key = KbName('Escape');
    
    % ׼��ʵ�����
    for i = 1:num
        sound_data{i, 5} = unifrnd(0.5,1.2); % ע�ӵ�ʱ��   
        sound_data{i, 6} = 'Beep';
    end
    
    % ����ָ����
    exp_instruction = Screen('MakeTexture', w, imread('sound_exp\pic\sound_instruction.tif'));
    exp_end = Screen('MakeTexture', w, imread('sound_exp\pic\exp_end.tif'));
    
    Screen('DrawTexture', w, exp_instruction, []);
    Screen('Flip', w);
    KbStrokeWait; % ���Ķ���ָ��������������
    
    % ���ִ̼�
    for trial = 1 : num
        % ����ע�ӵ�
        for i = 1:round(cell2mat(sound_data(trial, 5)) / ifi)
            Screen('DrawDots', w, [x_center; y_center], 30, [255,255,255], [], 1);
            Screen('Flip', w);
        end
        
        % ���ִ̼�
        freq = 48000; % ��Ƶ�Ĳ���Ƶ��
        % ������Ƶ
        pahandle = PsychPortAudio('Open', [], 1, 1, freq, 2);
        PsychPortAudio('Volume', pahandle, 0.5); %����50%
        [myBeep, samplingRate] = MakeBeep(500, 0.5, freq); %�������١�
        PsychPortAudio('FillBuffer', pahandle, [myBeep; myBeep]); %����Ƶת��Ϊ������
        startTime = PsychPortAudio('Start', pahandle, 1, 0, 1);
        
        [startTime, endPositionSecs, xruns, estStopTime] = PsychPortAudio('Stop', pahandle, 1, 1);
        %sound_data{i,7} = estStopTime - startTime;  % PsychPortAudio timing
        WaitSecs(0.1);
        
        [keyisdown, secs, keycode] = KbCheck;
        
        vbl = Screen('Flip', w, vbl+(1 - 0.5)*ifi);
        
        % ʹ�ű��ڳ��ִ̼����500ms�ڣ���������whileѭ���ڵ����  
        t0 = GetSecs;
        while GetSecs - t0 < 1
            % ��鱻�԰��µİ���
            [keyisdown, secs, keycode] = KbCheck;
            %���������Esc������ֱ�ӽ����ű�
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
    
    sca;

    % PsychPortAudio�Ĺر�
    PsychPortAudio('Close', pahandle);
     
    % ���������ļ�
   % header = {'SubjectNumber', 'Gender', 'Age', 'Handedness',...
    %    'DotsTime', 'ExpIterm', 'Resp', 'RT', 'ACC'};
    %data_table = cell2table(sound_data, 'VariableNames', header);
    
    % ����csv�ļ�
    %exp_data = strcat('sound_exp\data\', 'sound_exp_', char(sound_data{1,1}), '_', date, '.csv');
    %writetable(data_table, exp_data);
    
    % �ɹ����б�־
    disp('Succeed!');
    f = parfeval(p,@saveFile,1,sound_data,2,num);
    disp(fetchOutputs(f));
    
catch
    ShowCursor; % ���������ʾ���ָ��
    sca;
    psychrethrow(psychlasterror); % ��ʾ�������λ��
end

end