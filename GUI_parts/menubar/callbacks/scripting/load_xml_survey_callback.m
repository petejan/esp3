function load_xml_survey_callback(~,~,main_figure)
layers=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');
app_path=getappdata(main_figure,'App_path');



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
%     try
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
        end
        
        %     profile off;
        %     profile on;
        %
        
        layers=surv_obj.SurvInput.load_files_from_survey_input('PathToMemmap',app_path.data_temp,'layers',layers,'Fieldnames',{'power','sv'});
        surv_obj.generate_output(layers);
        
        %     profile off;
        %     profile viewer;
        %
        save(fullfile(PathToFile,[surv_obj.SurvInput.Infos.Title '_survey_output.mat']),'surv_obj');
        outputFile=fullfile(PathToFile,[surv_obj.SurvInput.Infos.Title '_mbs_output.txt']);
        surv_obj.print_output(outputFile);
        
        

%     catch err
%         disp(err.message);
%         warning('Could not process survey described in file %s\n',Filename{i});
%     end
end

if ~isempty(layers)
    [~,found]=find_layer_idx(layers,0);
else
    found=0;
end
if  found==1
    layers=layers.delete_layers(0);
end

if ~isempty(layers)
    layer=layers(end);
    setappdata(main_figure,'Layer',layer);
    setappdata(main_figure,'Layers',layers);
    
    update_display(main_figure,1);
end
end