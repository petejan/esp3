%% get_gps_data_from_db.m
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
% * 2017-05-25: first version (Yoann Ladroit).
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function [gps_data,files]=get_gps_data_from_db(layer_obj)


[pathtofile,~,~]=cellfun(@fileparts,layer_obj.Filename,'UniformOutput',0);
pathtofile=unique(pathtofile);
nb_data=0;
gps_data=gps_data_cl();
files={};
for ip=1:length(pathtofile)
    fileN=fullfile(pathtofile{ip},'echo_logbook.db');
    if exist(fileN,'file')==0
        return;
    end
    
    dbconn=sqlite(fileN,'connect');
    %files_db=dbconn.fetch('select Filename from gps_data');
    %         if ~any(strcmp([fileOri extN],files_db))
    gps_data_table=dbconn.fetch('select name FROM sqlite_master WHERE type=''table'' AND name=''gps_data''');
    if ~isempty(gps_data_table)
        gps_data_temp=dbconn.fetch('select Filename,Lat,Long,Time from gps_data');
    end
    
    %         end
    close(dbconn);
    
    for id=1:size(gps_data_temp,1)
       nb_data= nb_data+1;
        lat=str2double(strsplit(gps_data_temp{id,2}));
        lon=str2double(strsplit(gps_data_temp{id,3}));
        time=datenum(strsplit(gps_data_temp{id,4}),'yyyymmddHHMMSSFFF');
        gps_data(nb_data)=gps_data_cl('Lat',lat,'Long',lon,'Time',time);      
        files{nb_data}=gps_data_temp{id,1};
    end
end



end