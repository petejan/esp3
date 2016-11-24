    function start_date=get_start_date_from_raw(file)


[~,temp_file,~]=fileparts(file);
idx_str=strfind(temp_file,'D');
if ~isempty(idx_str)
    out=textscan(temp_file(idx_str(1):end),'D%d-T%d');
    if ~isempty(out{1})&&~isempty(out{2})
        start_date=datenum(([num2str(out{1},'%08d') num2str(out{2},'%06d')]),'yyyymmddHHMMSS');
    else
        start_date=0;
    end
else
    start_date=0;
end