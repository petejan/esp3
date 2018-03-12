function survey_data=get_survey_data_from_db(filenames)

if isempty(filenames)
    survey_data={};
    return;
end

if~iscell(filenames)
    filenames ={filenames};
end

survey_data=cell(1,numel(filenames));

for ip=1:length(filenames)
    
    if isfolder(filenames{ip})
        path_f=filenames{ip};
    else
        [path_f,file,ext]=fileparts(filenames{ip});
    end
    
    db_file=fullfile(path_f,'echo_logbook.db');
    
    if ~(exist(db_file,'file')==2)
        continue;
    end
    
    idata=1;
    dbconn=sqlite(db_file,'connect');
    createlogbookTable(dbconn);
    
    survey_data_db=dbconn.fetch('select Voyage,SurveyName from survey ');
    
    if ~isfolder(filenames{ip})
        curr_file_data=dbconn.fetch(sprintf('select Snapshot,Type,Stratum,Transect,StartTime,EndTime,Comment from logbook where Filename like "%s%s"',file,ext));
        nb_data=size(curr_file_data,1);
        
        for id=1:nb_data
            survey_data{ip}{idata}=survey_data_cl('Voyage',survey_data_db{1},...,...
                'SurveyName',survey_data_db{2},...
                'Type',curr_file_data{id,2},...
                'Snapshot',curr_file_data{id,1},...
                'Stratum',curr_file_data{id,3},...
                'Transect',curr_file_data{id,4},...
                'StartTime',datenum(curr_file_data{id,5}),...
                'EndTime',datenum(curr_file_data{id,6}));
            idata=idata+1;
        end
    else
        survey_data{ip}{1}=survey_data_cl('Voyage',survey_data_db{1},...,...
            'SurveyName',survey_data_db{2});
    end
     close(dbconn);
    
end




end
