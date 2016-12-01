function export_metadata_to_html_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

[path_lay,~]=layer.get_path_files();
db_file=fullfile(path_lay{1},'echo_logbook.db');

if ~(exist(db_file,'file')==2)
    initialize_echo_logbook_dbfile(path_f,0)
end

%surv_data_struct=import_survey_data_db(db_file);

dbconn=sqlite(db_file,'connect');

data_logbook=dbconn.fetch('select Filename,Snapshot,Stratum,Transect,Comment,StartTime,EndTime from logbook order by datetime(StartTime)');
data_survey=dbconn.fetch('select Voyage,SurveyName from survey');
dbconn.close();
ColHeads={'Filename','Snapshot','Stratum','Transect','Comment','StartTime','EndTime'};

pathname=path_lay{1};
filename=[data_survey{1} '_' data_survey{2} '_logbook.html'];
if isequal(filename,0) || isequal(pathname,0)
    return;
end

snaps=cell2mat(data_logbook(:,2));
strat=data_logbook(:,3);
trans=cell2mat(data_logbook(:,4));

[~,~,strat_vec_num]=unique(strat);

[~,iu,~]=unique([snaps strat_vec_num trans],'rows');

cols=cell(1,size(data_logbook,2)+1);
cols{1}='#FE0000';
cols(iu+1)={'#ADE6AB'};
cols(cellfun(@isempty,cols))={'#E6ABB9'};
html_table([ColHeads;data_logbook], fullfile(pathname,filename),...
    'DataFormatStr','%.0f',...
    'FirstRowIsHeading',1,...
    'RowBGColour',cols,...
    'Caption',sprintf('Voyage: %s Survey: %s',data_survey{1},data_survey{2}),...
    'Title',sprintf('Voyage: %s Survey: %s',data_survey{1},data_survey{2}));
    
    web(fullfile(pathname,filename),'-browser');
    
end