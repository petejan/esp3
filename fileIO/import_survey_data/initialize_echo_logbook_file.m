function initialize_echo_logbook_file(datapath)
disp('Creating .csv logbook file, this might take a couple minutes...');
list_raw=ls(fullfile(datapath,'*.raw'));

nb_files=size(list_raw,1);

file_name=fullfile(datapath,'echo_logbook.csv');
if exist(file_name,'file')==2
    return;
end

fid=fopen(file_name,'w+');

if fid==-1
    fclose('all');
    fid=fopen(file_name,'w+');
    if fid==-1
        warning('Could not initialize the .csv logbook file');
        return;
    end
end


fprintf(fid,'Voyage,SurveyName,Filename,Snapshot,Stratum,Transect,StartTime,EndTime\n');

for i=1:nb_files
    [start_date,end_date]=start_end_time_from_file(fullfile(datapath,list_raw(i,:)));
    endTimeStr=datestr(end_date,'yyyymmddHHMMSS');
    startTimeStr=datestr(start_date,'yyyymmddHHMMSS');
    fprintf(fid,',,%s,0,,0,%s,%s\n',strrep(list_raw(i,:),' ',''),startTimeStr,endTimeStr);
end

fclose(fid);



end