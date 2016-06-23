function [layers,surv_obj]=process_surveys(Filenames,varargin)

p = inputParser;

addRequired(p,'Filenames',@(x) ischar(x)|iscell(x));
addParameter(p,'layers',layer_cl.empty(),@(obj) isa(obj,'layer_cl'));
addParameter(p,'origin','xml',@ischar);
addParameter(p,'cvs_root','',@ischar);
addParameter(p,'data_root','',@ischar);
addParameter(p,'PathToMemmap','',@ischar);
addParameter(p,'tag','raw',@(x) ischar(x));

parse(p,Filenames,varargin{:});

if ~iscell(Filenames)
    Filenames={Filenames};
end

for i=1:length(Filenames)
    try
        surv_obj=survey_cl();
        
        switch p.Results.origin
            
            case 'mbs'
                curr_mbs=Filenames{i};
                
                if~strcmp(curr_mbs,'')
                    [fileNames,outDir]=get_mbs_from_esp2(p.Results.cvs_root,'MbsId',curr_mbs,'Rev',[]);
                end
                
                mbs=mbs_cl();
                mbs.readMbsScript(p.Results.data_root,fileNames{1});
                rmdir(outDir,'s');
                
                surv_obj.SurvInput=mbs.mbs_to_survey_obj('type',p.Results.tag);
                
            case 'xml'
                surv_obj.SurvInput=parse_survey_xml(Filenames{i});
                if isempty(surv_obj.SurvInput)
                    warning('Could not parse the File describing the survey...');
                    continue;
                end
                
                [valid,~]=surv_obj.SurvInput.check_n_complete_input();
                
                if valid==0
                    warning('It looks like there is a problem with XML survey file %s\n',Filenames{i});
                    continue;
                end
        end
        
        if isempty(surv_obj.SurvInput.Algos)
            fields_req={'power','sv'};
        else
            fields_req={};
        end
        
         layers=surv_obj.SurvInput.load_files_from_survey_input('PathToMemmap',p.Results.PathToMemmap,'cvs_root',p.Results.cvs_root,'origin',p.Results.origin,'layers',p.Results.layers,'Fieldnames',fields_req);

    catch err
        disp(err.message);
        warning('Problem loading files from %s\n',Filenames{i});
        continue;
    end
        
    try
        surv_obj.generate_output(layers);
        [PathToFile,~,~]=fileparts(layers(1).Filename{1});
        save(fullfile(PathToFile,[surv_obj.SurvInput.Infos.Title '_survey_output.mat']),'surv_obj');
        outputFile=fullfile(PathToFile,[surv_obj.SurvInput.Infos.Title '_mbs_output.txt']);
        surv_obj.print_output(outputFile);
        fprintf(1,'Results save to %s \n',outputFile);
        
        
    catch err
        disp(err.message);
        warning('Could not process survey described in file %s\n',Filenames{i});
    end
end

end