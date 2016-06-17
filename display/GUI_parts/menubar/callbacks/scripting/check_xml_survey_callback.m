function check_xml_survey_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');


if ~isempty(layer)
    if ~isempty(layer(1).Filename)
        [path_f,~,~]=fileparts(layer.Filename{1});
    else
        path_f=pwd;
    end
    
else
    path_f=pwd;
end

[Filename,PathToFile]= uigetfile({fullfile(path_f,'*.xml')}, 'Pick a survey xml file','MultiSelect','on');
if ~iscell(Filename)
if Filename==0
    return;
end
Filename={Filename};
end

for i=1:length(Filename)
    %try
    surv_obj=survey_cl();
    surv_obj.SurvInput=parse_survey_xml(fullfile(PathToFile,Filename{i}));
    
    if isempty(surv_obj.SurvInput)
        warning('Could not parse the File describing the survey...');
        continue;
    end
    
    [valid,~]=surv_obj.SurvInput.check_n_complete_input();
    
    if valid==0
        warning('It looks like there is a problem with XML survey file %s\n',Filename{i});
        continue;
    else
        disp('Script appears to be valid...') 
    end
   
end