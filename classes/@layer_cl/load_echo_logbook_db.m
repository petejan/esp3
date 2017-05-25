%% load_echo_logbook_db.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |layers_obj|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-04-02: header (Alex Schimel).
% * YYYY-MM-DD: first version (Yoann Ladroit). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function load_echo_logbook_db(layers_obj)

pathtofile={};
incomplete=0;
for ilay=1:length(layers_obj)
    [path_temp,~,~]=cellfun(@fileparts,layers_obj(ilay).Filename,'UniformOutput',0);
    pathtofile=union(pathtofile,path_temp);
end

pathtofile=unique(pathtofile);

for ip=1:length(pathtofile)
    
    fileN=fullfile(pathtofile{ip},'echo_logbook.db');
    
    if exist(fileN,'file')==0
        initialize_echo_logbook_dbfile(pathtofile{ip},0);
    end
    
    dbconn=sqlite(fileN,'connect');
    
    files_db=dbconn.fetch('select Filename from logbook');
    close(dbconn);
    
   
    dir_raw=dir(fullfile(pathtofile{ip},'*.raw'));
    dir_asl=dir(fullfile(pathtofile{ip},'*A'));
    
    list_raw=union({dir_raw([dir_raw(:).isdir]==0).name},{dir_asl([dir_asl(:).isdir]==0).name});
    if ~isempty(setdiff(list_raw,files_db))
        incomplete=1;
        fprintf('%s incomplete, we''ll update it\n',fileN);
    end
    
end


layers_obj.add_survey_data_db();

if incomplete>0
    layers_obj.update_echo_logbook_dbfile();
end

end