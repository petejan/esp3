function obj=create_line_from_SupervisorLog(filename)
    [timestamp,pressure] = importSupervisorLog(filename,2,inf);
    timestamp(end)=[];
    if isempty(pressure)
        obj=[];
        return; 
    end
    timestamp(end)=[];
    pressure(end)=[];
    len=nanmin(length(timestamp),length(pressure));
    timestamp=timestamp(1:len);
    pressure=pressure(1:len);
    
    depth=pressure/0.993117063157399;
    time=cellfun(@(x) datenum(x,'yyyy-mm-ddTHH:MM:SS'),timestamp);
    obj=line_cl('Tag','Imported from Supervisor Log','Range',depth,'Time',time,'File_origin',filename,'UTC_diff',0);
end