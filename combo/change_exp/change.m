function []=change()

clear;
clc;
sca;
%p = gcp();

% Screen('Preference', 'SkipSyncTests', 2);
% ��ʵ���жϵ�N���̼��͵�ǰ�̼��Ƿ�һ�£����һ���밴T���������һ���밴F��

try
    % �����洢���ݵľ���
    % change_data = cell(10,9);
    
    % �ռ�����ʵ���ߵ���Ϣ
    prompt = {'Subject Number','Gender[1 = m, 2 = f]','Age','Handeness[1 = left, 2 = right]','n����ֵ'};
    dlg_title = 'Exp infor'; 
    %num_line = 1;
    def_answer = {'1','1','18','1','2'};
    subinfo = inputdlg(prompt,dlg_title,[1, 50],def_answer);
    n_num = str2double(char(subinfo(5)));
    
    
    %�̼�
    fix = '+';
    probe = {'A',1;'B',2};
    probe = repmat(probe,5,1);
    randIndex = randperm(length(probe));
    probe= probe(randIndex,:);

    %ʱ��
    dura.fix = 0.5;
    dura.probe = 2;
    dura.feed = 0.5;

    %����
    KbName('UnifyKeyNames');
    key.escape = KbName('escape');
    key.t = KbName('t');
    key.f = KbName('f');

    %��ɫ
    rgb.bk = [0 0 0];
    rgb.font = [255 255 255];
    %����
    AssertOpenGL;
    Screen('Preference', 'SkipSyncTests', 1);
    screens = Screen('Screens');
    maxscreens = max(screens);
    [win,~] = Screen('OpenWindow',maxscreens,rgb.bk);
    
    HideCursor;
    
    slack = Screen('GetFlipInterval',win)/2;
    
    % ����ָ����
    %ָ���������
    exp_instruction = Screen('MakeTexture', win, imread('change_exp\pic\n-back_instruction.tif'));
    exp_end = Screen('MakeTexture', win, imread('change_exp\pic\exp_end.tif'));
    Screen('DrawTexture', win, exp_instruction, []);
    Screen('Flip', win);
    KbStrokeWait; % ���Ķ���ָ��������������
    
    probe = repmat(probe,4,1);
    randIndex = randperm(length(probe));
    probe= probe(randIndex,:);

    data_table = repmat(struct('SubNo',1),length(probe),1);%Ԥ�����ڴ� �����������
    ab = n_num;

    while ab ~= 0
    for trials = 1:n_num
        %ע�ӵ�
        Screen('TextSize',win,28);
        Screen('TextFont',win,'Times New Roman');
        DrawFormattedText(win,fix,'center','center',rgb.font);
        tFix = Screen('Flip',win);

        %�̼�
        Screen('TextSize',win,100);
        Screen('TextFont',win,'Times New Roman');
        DrawFormattedText(win,double(probe{trials,1}),'center','center',rgb.font);
        tFix = Screen('Flip',win,tFix+dura.fix-slack);

        %����
        Screen('TextSize',win,28);
        Screen('TextFont',win,'Times New Roman');
        DrawFormattedText(win,fix,'center','center',rgb.font);
        Screen('Flip',win,tFix+dura.probe-slack);
        WaitSecs(dura.feed);
    end
    ab = 0;
    end

    for trials = (n_num+1):length(probe)

        %ע�ӵ�
        Screen('TextSize',win,28);
        Screen('TextFont',win,'Times New Roman');
        DrawFormattedText(win,fix,'center','center',rgb.font);
        tFix = Screen('Flip',win);

        %�̼�
        Screen('TextSize',win,100);
        Screen('TextFont',win,'Times New Roman');
        DrawFormattedText(win,double(probe{trials,1}),'center','center',rgb.font);
        tFix = Screen('Flip',win,tFix+dura.fix-slack);

        while true %�����ж�
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
        %��Ӧ�����ռ�

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

    % ���ֽ����1s���˳�
    for i = 1:round(2 / Screen('GetFlipInterval',win))
        Screen('DrawTexture', win, exp_end, []);
        Screen('Flip', win);
    end
    
    sca;
    %��������
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

        data_table(trials,1).Test = probe{trials,1};%��ǰ��Ļ��ʾ��ֵ

        data_table(trials+n_num,1).nbTest = probe{trials,1}; %��Ҫ��Ӧ��ֵ
    end

    columheader ={'SubNo','Gender','Age','Handedness','Test','nbTest','ACC','RT'};
    data_table = orderfields(data_table,columheader);
    ret = [columheader;(struct2cell(data_table))'];
    ret = ret(1:(trials+1),:); %���ζ�������
    xlswrite(['change_exp\data\','Nback_',char(subinfo(1)),'_',date,'.xls'],ret);
    
    % �ɹ����б�־
    disp('Succeed!');
%     f = parfeval(p,@saveFile,1,data_table,3);
%     disp(fetchOutputs(f));
    
catch
    ShowCursor; % ���������ʾ���ָ��
    sca;
    psychrethrow(psychlasterror); % ��ʾ�������λ��
end
end