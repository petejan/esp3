function obj=create_line_from_xls(filename)
    data_struct = csv2struct(filename);
   
    if ~isfield(data_struct,'Depth')
        obj=[];
        return; 
    end
    if isfield(data_struct,'Timestamp')
        time=cellfun(@(x) datenum(x,'dd/mm/yyyy HH:MM:SS.FFF'),data_struct.Timestamp);
    elseif isfield(data_struct,'Time')
        time=cellfun(@(x) datenum(x,'yyyy-mm-dd HH:MM:SS.FFF'),data_struct.Time);
    else        
       obj=[];
       return;
    end
    

    fprintf('\nRBR file starts at %s and finishes at %s\n',datestr(time(1)),datestr(time(end)));
    obj=line_cl('Tag','Imported from Supervisor Log','Range',abs(data_struct.Depth),'Time',time,'File_origin',{filename},'UTC_diff',0,'Data',data_struct.Temperature);
end