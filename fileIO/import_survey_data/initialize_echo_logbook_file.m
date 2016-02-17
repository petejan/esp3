function initialize_echo_logbook_file(datapath)
     list_raw=ls(fullfile(datapath,'*.raw'));
     
     nb_files=size(list_raw,1);
     
     file_name=fullfile(datapath,'echo_logbook.csv');
     %fields=properties(survey_data_cl);
     %[~,voyage_init,~]=fileparts(datapath);
     fid=fopen(file_name,'w+');
     
     if fid==-1
         warning('Could not initialize the .csv logbook file');
         return;
     end
     
     fprintf(fid,'Datapath,Voyage,SurveyName,Filename,Snapshot,Stratum,Transect\n');
     
     for i=1:nb_files
        fprintf(fid,'%s,,,%s,,,\n',datapath,strrep(list_raw(i,:),' ',''));
     end
     
     fclose(fid);
     
    
     

end