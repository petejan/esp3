%% recompute_region_callback.m
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
function recompute_region_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
Transceiver=layer.Transceivers(idx_freq);
list_reg = layer.Transceivers(idx_freq).regions_to_str();
region_tab_comp=getappdata(main_figure,'Region_tab');

if ~isempty(list_reg)
    idx_reg=get(region_tab_comp.tog_reg,'value');
    if idx_reg>length(Transceiver.Regions)
        return;
    end
    active_reg=Transceiver.Regions(idx_reg);
else
    return
end


data_types=get(region_tab_comp.data_type,'string');
data_type_idx=get(region_tab_comp.data_type,'value');
data_type=data_types{data_type_idx};
active_reg.Type=data_type;

tag=get(region_tab_comp.tag,'string');
id=ceil(str2double(get(region_tab_comp.id,'string')));

if isnan(id)||id<=0
    id=active_reg.ID;
end
set(region_tab_comp.id,'string',num2str(id,'%.0f'));

active_reg.Tag=tag;
active_reg.ID=id;

refs=get(region_tab_comp.tog_ref,'string');
ref_idx=get(region_tab_comp.tog_ref,'value');
ref=refs{ref_idx};
active_reg.Reference=ref;

w_units=get(region_tab_comp.cell_w_unit,'string');
w_unit_idx=get(region_tab_comp.cell_w_unit,'value');
w_unit=w_units{w_unit_idx};
active_reg.Cell_w_unit=w_unit;

h_units=get(region_tab_comp.cell_h_unit,'string');
h_unit_idx=get(region_tab_comp.cell_h_unit,'value');
h_unit=h_units{h_unit_idx};
active_reg.Cell_h_unit=h_unit;

active_reg.Cell_h=str2double(get(region_tab_comp.cell_h,'string'));
active_reg.Cell_w=str2double(get(region_tab_comp.cell_w,'string'));

layer.Transceivers(idx_freq).rm_region_id(active_reg.Unique_ID)

layer.Transceivers(idx_freq).add_region(active_reg);

list_reg = layer.Transceivers(idx_freq).regions_to_str();

if ~isempty(list_reg)
    set(region_tab_comp.tog_reg,'string',list_reg);
    set(region_tab_comp.tog_reg,'value',length(list_reg));
else
    set(region_tab_comp.tog_reg,'string',{'--'});
end
setappdata(main_figure,'Region_tab',region_tab_comp);
setappdata(main_figure,'Layer',layer);
update_regions_tab(main_figure,[]);
update_reglist_tab(main_figure,[],0);
display_regions(main_figure,'both');
order_stacks_fig(main_figure);


end
