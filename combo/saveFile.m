function flag = saveFile(datacell,num,trail)
    
    if num == 1
       for trial = 1:trail
            if str2double(datacell{trial, 2}) == 1
                datacell{trial,2} = 'Male';
            else
                datacell{trial, 2} = 'Female';
            end
            if  str2double(datacell{trial, 4}) == 1
                datacell{trial, 4} = 'Left';
            else
                datacell{trial, 4} = 'Right';
            end
       end
        %pause(30);
        % 保存数据文件
        header = {'SubNo', 'Gender', 'Age', 'Handedness',...
        'DotsTime', 'Arrow', 'Resp', 'RT', 'ACC'};
        %data = datacell;
        data_table = cell2table(datacell, 'VariableNames', header);
    
        % 创建csv文件
        exp_data = strcat('visual_exp\data\', 'visual_exp_', char(datacell{1,1}), '_', date, '.csv');
        writetable(data_table, exp_data);
        flag = 1;
        disp('Visual Succeed!');
    elseif num == 2
        for trial = 1:trail
            %arrow_data(trials,1).SubNo = str2double(char(subinfo(1)));
            if str2double(datacell{trial, 2}) == 1
                datacell{trial,2} = 'Male';
            else
                datacell{trial, 2} = 'Female';
            end
            %arrow_data(trials,1).Age = str2double(char(subinfo(3)));
            if  str2double(datacell{trial, 4}) == 1
                datacell{trial, 4} = 'Left';
            else
                datacell{trial, 4} = 'Right';
            end

    %         data_table(trials,1).Test = probe{trials,1};%当前屏幕显示的值
    % 
    %         data_table(trials+n_num,1).nbTest = probe{trials,1}; %需要反应的值
        end
        % pause(30);
        % 保存数据文件
        header = {'SubNo', 'Gender', 'Age', 'Handedness',...
            'DotsTime', 'ExpIterm', 'Resp', 'RT', 'ACC'};
        data_table = cell2table(datacell, 'VariableNames', header);

        % 创建csv文件
        exp_data = strcat('sound_exp\data\', 'sound_exp_', char(datacell{1,1}), '_', date, '.csv');
        writetable(data_table, exp_data);
        flag = 2;
        disp('Sound Succeed!');
    elseif num == 3
        data_table = repmat(struct('SubNo',1),length(datacell),1);%预分配内存 提高运行速率
        %数据整理
        for trials = 1:length(datacell)
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

            data_table(trials,1).Test = datacell{trials,1};%当前屏幕显示的值

            data_table(trials+n_num,1).nbTest = datacell{trials,1}; %需要反应的值
        end
        columheader ={'SubNo','Gender','Age','Handedness','Test','nbTest','ACC','RT'};
        data_table = orderfields(datacell,columheader);
        ret = [columheader;(struct2cell(data_table))'];
        ret = ret(1:(trials+1),:); %修饰多余数据
        xlswrite(['change_exp\data\','Nback_',char(subinfo(1)),'_',date,'.xls'],ret);
        flag = 3;
    else 
        flag = 0;
        disp('Save Erro');        
    end
    
end