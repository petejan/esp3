function initialize_echo_logbook_file(datapath)
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
        start_date=get_start_date_from_raw(list_raw(i,:));
        fprintf(fid,' , ,%s,0, ,0,%.0f,1\n',strrep(list_raw(i,:),' ',''),start_date);
     end
     
     fclose(fid);
     
    
 
end