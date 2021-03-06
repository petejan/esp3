function save_att_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end


layer=getappdata(main_figure,'Layer');

curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,~]=layer.get_trans(curr_disp);

att_obj=trans_obj.AttitudeNavPing;
filenames=layer.Filename;

for i=1:length(filenames)
    
    [path_f,fileN_ori,~]=fileparts(filenames{i});
    fileN=fullfile(path_f,[fileN_ori,'_att_data.csv']);
    
    idx_f=find(trans_obj.Data.FileId==i);
    att_obj.save_attitude_to_file(fileN,idx_f);
    
    fprintf('Attitude for file %s saved\n',fileN);
    
    [stat,~]=system(['start notepad++ ' fileN]);
    
    if stat~=0
        disp('You should install Notepad++...');
        system(['start ' fileN]);
    end

    
end