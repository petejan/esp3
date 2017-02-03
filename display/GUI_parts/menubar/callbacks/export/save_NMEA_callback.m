function save_NMEA_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

layer=getappdata(main_figure,'Layer');
filenames=layer.Filename;

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');

for i=1:length(filenames)
    Filename=filenames{i};
    [path_f,fileN,~]=fileparts(filenames{i});
    fileIdx=fullfile(path_f,'echoanalysisfiles',[fileN '_echoidx.mat']);
    if exist(fileIdx,'file')==0
        idx_raw_obj=idx_from_raw(Filename,p.Results.load_bar_comp);
        save(fileIdx,'idx_raw_obj');
    else
        load(fileIdx);
        [~,et]=start_end_time_from_file(Filename);
        dgs=find((strcmp(idx_raw_obj.type_dg,'RAW0')|strcmp(idx_raw_obj.type_dg,'RAW3'))&idx_raw_obj.chan_dg==nanmin(idx_raw_obj.chan_dg));
        if et-idx_raw_obj.time_dg(dgs(end))>2*nanmax(diff(idx_raw_obj.time_dg(dgs)))
            fprintf('Re-Indexing file: %s\n',Filename);
            delete(fileIdx);
            idx_raw_obj=idx_from_raw(Filename,p.Results.load_bar_comp);
            save(fileIdx,'idx_raw_obj');
        end
    end
    
    [~,~,NMEA,~]=data_from_raw_idx_cl_v3(path_f,idx_raw_obj,'GPSOnly',1,'load_bar_comp',load_bar_comp);
    
    fileNMEA=fullfile(path_f,[fileN '_NMEA.csv']);
    
    NMEA.time=cellfun(@(x) datestr(x,'dd/mm/yyyy HH:MM:SS'),(num2cell(NMEA.time')),'UniformOutput',0);
    NMEA.string=NMEA.string';
    struct2csv(NMEA,fileNMEA);
    
    fprintf('NMEA for file %s saved\n',fileN);
    [stat,~]=system(['start notepad++ ' fileNMEA]);
    
    if stat~=0
        disp('You should install Notepad++...');
        system(['start ' fileNMEA]);
    end
    
    
end


hide_status_bar(main_figure);