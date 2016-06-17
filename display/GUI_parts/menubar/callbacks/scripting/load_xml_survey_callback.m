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

Filenames=cellfun(@(x) fullfile(PathToFile,x),Filename,'UniformOutput',0);

[layers,~]=process_surveys(Filenames,'PathToMemmap',app_path.data_temp,'layers',layers,'origin','xml');


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