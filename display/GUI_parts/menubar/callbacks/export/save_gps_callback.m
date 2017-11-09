function save_gps_callback(~,~,main_figure,def)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
idx_freq=find(layer.Frequencies==curr_disp.Freq);

trans_obj=trans_obj;
gps_obj=trans_obj.GPSDataPing;
filenames=layer.Filename;

for i=1:length(filenames)
    
    [path_f,fileN_ori,~]=fileparts(filenames{i});
    if def==1 
        fileN=fullfile(path_f,[fileN_ori,'_gps.csv']);
    else
        fileN=fullfile(path_f,[fileN_ori,'_gps_data.csv']);
    end
    idx_f=find(trans_obj.Data.FileId==i);
    gps_obj.save_gps_to_file(fileN,idx_f);
    
    fprintf('Position for file %s saved\n',fileN);
    
    [stat,~]=system(['start notepad++ ' fileN]);
    
    if stat~=0
        disp('You should install Notepad++...');
        system(['start ' fileN]);
    end
    

    
end