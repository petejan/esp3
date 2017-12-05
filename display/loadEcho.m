%% loadEcho.m
%
% TODO
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
% * |main_figure|: Handle to main ESP3 window
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments updated according to new format (Alex Schimel)
% * 2017-03-13: comments and header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function loadEcho(main_figure)

if isempty(main_figure)
    return;
end

layer  = getappdata(main_figure,'Layer');
layers = getappdata(main_figure,'Layers');

if isempty(layers)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');
remove_interactions(main_figure);
disable_listeners(main_figure);
uiundo(main_figure,'clear');

nb_layers = length(layers);


if strcmp(layer.Unique_ID,curr_disp.CurrLayerID) && nb_layers==curr_disp.NbLayers
    flag = 0;
    up_curr_disp=0;
elseif ~strcmp(layer.Unique_ID,curr_disp.CurrLayerID) && nb_layers<=curr_disp.NbLayers
    flag = 1;  
    up_curr_disp=0;
elseif nb_layers>curr_disp.NbLayers
    flag = 1;
    up_curr_disp=1;
end

if up_curr_disp>=1
    [display_config_file,~,~]=get_config_files();
    [~,fname,fext]=fileparts(display_config_file);
    filepath=fileparts(layer.Filename{1});
    disp_config_file=fullfile(filepath,[fname fext]);
    
    if exist(disp_config_file,'file')==2
        curr_disp_new=read_config_display_xml(disp_config_file);
    else
        [~,curr_disp_new,~,~]=load_config_from_xml_v2(0,1,0);
    end
    props=properties(curr_disp);
    
    for i=1:numel(props)
        if ~ismember((props{i}),{'Fieldnames' 'Fieldname' 'Type' 'Xaxes_current' 'Cax' 'Caxes' 'Freq'})
            curr_disp.(props{i})=curr_disp_new.(props{i});
        end
    end
end

curr_disp.CurrLayerID = layer.Unique_ID;
curr_disp.NbLayers    = nb_layers;
curr_disp.SecChannelIDs=layer.ChannelID;
curr_disp.SecFreqs=layer.Frequencies;

[trans_obj,idx_freq]=layer.get_trans(curr_disp);

if isempty(trans_obj)
    idx_freq = 1;
    %disp('Cannot Find Frequency...');
    curr_disp.ChannelID = layer.ChannelID{idx_freq};
    curr_disp.Freq = layer.Frequencies(idx_freq);
	[trans_obj,idx_freq]=layer.get_trans(curr_disp);
end
curr_disp.ChannelID = layer.ChannelID{idx_freq};

[~,found_field] = find_field_idx(trans_obj.Data,curr_disp.Fieldname);

if found_field == 0
    [~,found] = find_field_idx(trans_obj.Data,'sv');
    if found == 0
        field = trans_obj.Data.Fieldname{1};
    else
        field = 'sv';
    end
    curr_disp.setField(field);
end
setappdata(main_figure,'Curr_disp',curr_disp);
%old_nb=curr_disp.NbLayers;

curr_disp.Bot_changed_flag = 0;
curr_disp.Reg_changed_flag = 0;
curr_disp.UIupdate=1;

curr_disp.setActive_reg_ID({});

setappdata(main_figure,'Curr_disp',curr_disp);

update_display(main_figure,flag);

waitfor(curr_disp,'UIupdate',0)
axes_panel_comp=getappdata(main_figure,'Axes_panel');
axes_panel_comp.axes_panel.Parent.SelectedTab=axes_panel_comp.axes_panel;

enable_listeners(main_figure);

%curr_disp.CursorMode=curr_mode;
curr_disp.CursorMode='Normal';

enabled_obj=findobj(main_figure,'Enable','off');
set(enabled_obj,'Enable','on');

if ~isdeployed
    fprintf(1,'Currently %.0f active objects in ESP3\n\n',numel(findall(main_figure)));
end

end

