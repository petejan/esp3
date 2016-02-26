function valid=check_n_complete_input(surv_input_obj,varargin)

p = inputParser;

addRequired(p,'surv_input_obj',@(obj) isa(obj,'survey_input_cl'));

parse(p,surv_input_obj,varargin{:});

infos=surv_input_obj.Infos;
% options=surv_input_obj.Options;
% regions_wc=surv_input_obj.Regions_WC;
% algos=surv_input_obj.Algos;
% cal=surv_input_obj.Cal;

surveyName=infos.Title;
voyage=infos.Voyage;


snapshots=surv_input_obj.Snapshots;

valid=1;

fprintf('Checking survey input for %s  trip %s:\n',...
    surveyName,voyage);

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
    
    if ~isfield(snapshots{isn},'Stratum')
       fprintf('No stratum for %s Snapshot %.0f\n',surveyName,snap_num);
        continue;
    end
    
    stratum=snapshots{isn}.Stratum;
    
    file_name=fullfile(snapshots{isn}.Folder,'echo_logbook.csv');
    
    if exist(file_name,'file')==0
        initialize_echo_logbook_file(snapshots{isn}.Folder);
    end
    surv_data_struct=import_survey_data(snapshots{isn}.Folder,'echo_logbook.csv');
    
    for ist=1:length(stratum)
        
        if ~isfield(stratum{ist},'Name')
            fprintf('Stratum Name needs to be specified for %s Snapshot %.0f\n',surveyName,snap_num);
            valid=0;
            continue;
        end
        strat_name=stratum{ist}.Name;
        
        if ~isfield(stratum{ist},'Transects')
            fprintf('No transects for %s Snapshot %.0f Startum %s\n',surveyName,snap_num,stratum{ist}.Name);
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
                
                 surv_temp=survey_data_cl('Voyage',voyage,...
            'SurveyName',surveyName,...
            'Snapshot',snap_num,...
            'Stratum',strat_name,...
            'Transect',trans_num);
        
            [pathtofiles,filenames]=surv_temp.get_files_from_surv_struct(surv_data_struct);
            idx_same=find(cellfun(@(x) strcmp(x,snapshots{isn}.Folder),pathtofiles)==0,1);
            if ~isempty(idx_same)
                fprintf('Some files from %s Snapshot %.0f Stratum %s Transect %.0f seem to be in another folder... Check the logbook\n',...
                    surveyName,snap_num,strat_name,trans_num);
                valid=0;
                continue;
            end
            
             fprintf(' Files added to Snapshot %.0f Stratum %s Transect %.0f:\n',...
                    snap_num,strat_name,trans_num);
            
            fprintf('%s \n',filenames{:});
            
            surv_input_obj.Snapshots{isn}.Stratum{ist}.Transects{itr}.files=filenames;
            end
        
        end
        
    end
     
end

if valid==0
    fprintf('Invalid XML script file for trip %s %s\n',voyage,surveyName);
end

end





