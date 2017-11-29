%% load_regions_tab.m
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
% * |main_figure|: TODO: write description and info on variable
% * |option_tab_panel|: TODO: write description and info on variable
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
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function load_regions_tab(main_figure,option_tab_panel)

region_tab_comp.region_tab=uitab(option_tab_panel,'Title','Regions');

reg_curr=region_cl();

uicontrol(region_tab_comp.region_tab,'Style','Text','String','Tag','units','normalized','Position',[0.7 0.55 0.1 0.15]);
region_tab_comp.tag=uicontrol(region_tab_comp.region_tab,'Style','edit','String',reg_curr.Tag,'units','normalized','Position', [0.8 0.55 0.15 0.15]);


uicontrol(region_tab_comp.region_tab,'Style','Text','String','Cell Width','units','normalized','Position',[0 0.3 0.2 0.1]);
uicontrol(region_tab_comp.region_tab,'Style','Text','String','Cell Height','units','normalized','Position',[0 0.1 0.2 0.1]);

region_tab_comp.cell_w=uicontrol(region_tab_comp.region_tab,'Style','edit','unit','normalized','position',[0.2 0.3 0.05 0.1],'string',reg_curr.Cell_w,'Tag','w');
region_tab_comp.cell_h=uicontrol(region_tab_comp.region_tab,'Style','edit','unit','normalized','position',[0.2 0.1 0.05 0.1],'string',reg_curr.Cell_h,'Tag','h');

set([region_tab_comp.cell_w region_tab_comp.cell_h],'callback',{@check_cell,main_figure})


units_w= {'pings','meters'};

units_h={'meters','samples'};

h_unit_idx=find(strcmp(reg_curr.Cell_h_unit,units_h));
w_unit_idx=find(strcmp(reg_curr.Cell_w_unit,units_w));

region_tab_comp.cell_w_unit=uicontrol(region_tab_comp.region_tab,'Style','popupmenu','String',units_w,'Value',w_unit_idx,'units','normalized','Position', [0.3 0.3 0.1 0.1],'Tag','w');
region_tab_comp.cell_h_unit=uicontrol(region_tab_comp.region_tab,'Style','popupmenu','String',units_h,'Value',h_unit_idx,'units','normalized','Position', [0.3 0.1 0.1 0.1],'Tag','h');
region_tab_comp.cell_w_unit_curr=get(region_tab_comp.cell_w_unit,'value');
region_tab_comp.cell_h_unit_curr=get(region_tab_comp.cell_w_unit,'value');
set(region_tab_comp.cell_w_unit ,'callback',{@tog_units,main_figure});
set(region_tab_comp.cell_h_unit ,'callback',{@tog_units,main_figure});


data_type={'Data' 'Bad Data'};
data_idx=find(strcmp(data_type,reg_curr.Type));
uicontrol(region_tab_comp.region_tab,'Style','Text','String','Data Type','units','normalized','Position',[0 0.65 0.2 0.1]);
region_tab_comp.data_type=uicontrol(region_tab_comp.region_tab,'Style','popupmenu','String',data_type,'Value',data_idx,'units','normalized','Position', [0.2 0.65 0.2 0.1]);


ref={'Surface','Bottom','Line'};
ref_idx=find(strcmp(reg_curr.Reference,ref));
uicontrol(region_tab_comp.region_tab,'Style','Text','String','Reference','units','normalized','Position',[0 0.45 0.2 0.1]);
region_tab_comp.tog_ref=uicontrol(region_tab_comp.region_tab,'Style','popupmenu','String',ref,'Value',ref_idx,'units','normalized','Position', [0.2 0.45 0.2 0.1]);


% str_create='<HTML><center><FONT color="Green"><b>Create</b></Font> ';
str_delete='<HTML><center><FONT color="Red"><b>Delete</b></Font> ';
str_delete_all='<HTML><center><FONT color="Red"><b>Del. All</b></Font> ';
% region_tab_comp.create_button=uicontrol(region_tab_comp.region_tab,'Style','pushbutton',...
%     'String',str_create,'units','normalized','pos',[0.5 0.3 0.1 0.15],...
%     'callback',{@create_region_callback,main_figure});

uicontrol(region_tab_comp.region_tab,'Style','pushbutton','String',str_delete,'units','normalized','pos',[0.5 0.3 0.15 0.15],'callback',{@delete_region_callback,main_figure,[]});
uicontrol(region_tab_comp.region_tab,'Style','pushbutton','String',str_delete_all,'units','normalized','pos',[0.65 0.3 0.15 0.15],'callback',{@delete_all_region_callback,main_figure});
uicontrol(region_tab_comp.region_tab,'Style','pushbutton','String','Del. Across Freq.','TooltipString','Delete Across Frequencies','units','normalized','pos',[0.65 0.1 0.15 0.15],'callback',{@rm_over_freq_callback,main_figure});
uicontrol(region_tab_comp.region_tab,'Style','pushbutton','String','Copy Across Freq.','TooltipString','Copy All Regions Across Frequencies','units','normalized','pos',[0.5 0.1 0.15 0.15],'callback',{@copy_to_other_freq,main_figure});

%set(findall(region_tab_comp.region_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'Region_tab',region_tab_comp);
end

% function create_region_callback(~,~,main_figure)
% curr_disp=getappdata(main_figure,'Curr_disp');
% curr_disp.CursorMode='Create Region';
% setappdata(main_figure,'Curr_disp',curr_disp);
% end

function copy_to_other_freq(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);

for uir=1:length(trans_obj.Regions)
    layer.copy_region_across(idx_freq,trans_obj.Regions(uir),[]);
end

setappdata(main_figure,'Layer',layer);
display_regions(main_figure,'all');
end

function rm_over_freq_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);

list_reg = trans_obj.regions_to_str();


if ~isempty(list_reg)
    layer.rm_region_across_id(curr_disp.Active_reg_ID);
end

setappdata(main_figure,'Layer',layer);

display_regions(main_figure,'all');
curr_disp.setActive_reg_ID(trans_obj.get_reg_first_Unique_ID());

end





