function [valid,files_to_load]=check_n_complete_input(surv_input_obj,varargin)

p = inputParser;

addRequired(p,'surv_input_obj',@(obj) isa(obj,'survey_input_cl'));

parse(p,surv_input_obj,varargin{:});

infos=surv_input_obj.Infos;
% options=surv_input_obj.Options;
% regions_wc=surv_input_obj.Regions_WC;
% algos=surv_input_obj.Algos;
% cal=surv_input_obj.Cal;

surveyName=infos.SurveyName;
voyage=infos.Voyage;


snapshots=surv_input_obj.Snapshots;

valid=1;

fprintf('\n\nChecking survey input for %s  Voyage %s:\n',...
    surveyName,voyage);
files_to_load={};

for isn=1:length(snapshots)
    
    if ~isfield(snapshots{isn},'Number')
        fprintf('Snapshot Number needs to be specified for %s\n',surveyName);
        valid=0;
        continue;
    end
    
    if ~isfield(snapshots{isn},'Folder')
        fprintf('Snapshot Folder needs to be specified for %s\n',surveyName);
        valid=0;
        return;
    end
    
    snap_num=snapshots{isn}.Number;
    snap_type=snapshots{isn}.Type;
    
    if ~isfield(snapshots{isn},'Stratum')
        fprintf('No stratum for %s Snapshot %.0f\n',surveyName,snap_num);
        continue;
    end
    
    stratum=snapshots{isn}.Stratum;
    
        
    if exist(snapshots{isn}.Folder,'dir')==0
        fprintf('Cannot find folder %s \n',snapshots{isn}.Folder);
        valid=0;
        continue;
    end
    
    file_name=fullfile(snapshots{isn}.Folder,'echo_logbook.db');
    
    if exist(file_name,'file')==0
        fprintf('No logbook in for %s \n',snapshots{isn}.Folder);
        valid=0;
        continue;
    end
    
    fprintf('\nLooking in folder %s\n',snapshots{isn}.Folder);
    dbconn=sqlite(file_name,'connect');
    
    for ist=1:length(stratum)
        
        if ~isfield(stratum{ist},'Name')
            fprintf('Stratum Name needs to be specified for %s Snapshot %.0f\n',surveyName,snap_num);
            valid=0;
            continue;
        end
        strat_name=stratum{ist}.Name;
        
        if ~isfield(stratum{ist},'Transects')
            fprintf('No transects for %s Snapshot %.0f Stratum %s\n',surveyName,snap_num,stratum{ist}.Name);
            valid=0;
            continue;
        end
        
        transects=stratum{ist}.Transects;
        for itr=1:length(transects)
            
            if ~isfield(transects{itr},'number')
                fprintf('Transect number needs to be specified for %s Snapshot %.0f Stratum %s\n',surveyName,snap_num,strat_name);
                valid=0;
                continue;
            end
            trans_num=transects{itr}.number;
            
            if ~isfield(transects{itr},'files')
                               
                filenames={};
                for itype=1:length(snap_type)
                    surv_temp=survey_data_cl('Voyage',voyage,...,...
                        'SurveyName',surveyName,...
                        'Type',snap_type{itype},...
                        'Snapshot',snap_num,...
                        'Stratum',strat_name,...
                        'Transect',trans_num);
                    filenames_tmp=get_files_from_db(dbconn,surv_temp);
                    filenames=union(filenames,filenames_tmp);
                end
               
                if ~isempty(filenames(:))
                    fprintf(' Files added to Snapshot %.0f Stratum %s Transect %.0f:\n',...
                        snap_num,strat_name,trans_num);                    
                    fprintf('%s \n',filenames{:});
                    surv_input_obj.Snapshots{isn}.Stratum{ist}.Transects{itr}.files=filenames;
                    files_to_load=[files_to_load filenames{:}];
                else
                    fprintf('!!!!!!!!!!!!No Files found in Snapshot %.0f Stratum %s Transect %.0f:\n',...
                        snap_num,strat_name,trans_num);
                    valid=0;
                end
            else
               files_to_load=[files_to_load surv_input_obj.Snapshots{isn}.Stratum{ist}.Transects{itr}.files{:}]; 
            end
        end
        
    end
    close(dbconn);
end

if valid==0
    fprintf('Invalid XML script file for Voyage %s %s\n',voyage,surveyName);
end

end





