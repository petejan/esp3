function load_xml_survey_callback(~,~,main_figure)
layers_old=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');
app_path=getappdata(main_figure,'App_path');

if ~isempty(layer)
    path=layer.PathToFile;
else
    path=pwd;
end

[Filename,PathToFile]= uigetfile({fullfile(path,'*.xml')}, 'Pick a survey xml file','MultiSelect','on');
if ~iscell(Filename)
if Filename==0
    return;
end
Filename={Filename};
end

for i=1:length(Filename)
    surv_obj=survey_cl();
    surv_obj.SurvInput=parse_survey_xml(fullfile(PathToFile,Filename{i}));
    
    if isempty(surv_obj.SurvInput)
        warning('Could not parse the File describing the survey...');
        return;
    end
%     profile off;
%     profile on;
%     
%     
    layers_new=surv_obj.SurvInput.load_files_from_survey_input('PathToMemmap',app_path.data);
    surv_obj.generate_output(layers_new);
    
%     profile off;
%     profile viewer;
%     
    save(fullfile(PathToFile,[surv_obj.SurvInput.Infos.Title '_survey_output.mat']),'surv_obj');
    outputFile=fullfile(PathToFile,[surv_obj.SurvInput.Infos.Title '_mbs_output.txt']);
    surv_obj.print_output(outputFile);

    layers_old=[layers_old layers_new];  
end

layers=layers_old;
if ~isempty(layers)
    [~,found]=find_layer_idx(layers,0);
else
    found=0;
end
if  found==1
    layers=layers.delete_layers(0);
end


layer=layers(end);
setappdata(main_figure,'Layer',layer);
setappdata(main_figure,'Layers',layers);

update_display(main_figure,1);

end