function export_metadata_to_csv_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

surv_data_struct=layer.get_logbook_struct();
if isempty(surv_data_struct)
    return;
end
   
struct_out=struct('Filename','','Snapshot',0,'Stratum','','Transect',0,'StartTime',0,'EndTime',1,'Comment','');
field_csv=fieldnames(struct_out);

for ifs=1:length(field_csv)
    struct_out.(field_csv{ifs})=surv_data_struct.(field_csv{ifs})';
end

for i=1:length(struct_out.Stratum)
    struct_out.StartTime(i)=datenum(num2str(struct_out.StartTime(i)),'yyyymmddHHMMSS');
    struct_out.EndTime(i)=datenum(num2str(struct_out.EndTime(i)),'yyyymmddHHMMSS');
end

struct_out.StartTime=datestr(struct_out.StartTime,'dd/mm/yyyy HH:MM:SS');
struct_out.EndTime=datestr(struct_out.EndTime,'dd/mm/yyyy HH:MM:SS');

path_lay=layer.get_path_files();

[filename, pathname] = uiputfile('*.xml',...
    'Save survey csv Metadata file',...
    fullfile(path_lay{1},[surv_data_struct.Voyage{1} '_' surv_data_struct.SurveyName{1} '_metadata.csv']));

if isequal(filename,0) || isequal(pathname,0)
    return;
end

struct2csv(struct_out,fullfile(pathname,filename));

end