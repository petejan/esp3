%% create_poly_region_func.m
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
% * |poly_r|: TODO: write description and info on variable
% * |poly_pings|: TODO: write description and info on variable
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
function create_poly_region_func(main_figure,poly_r,poly_pings)

if isempty(poly_r)||isempty(poly_pings)
    return;
end


layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
region_tab_comp=getappdata(main_figure,'Region_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
Transceiver=layer.Transceivers(idx_freq);
%
% shape_types=get(region_tab_comp.shape_type,'string');
% shape_type_idx=get(region_tab_comp.shape_type,'value');
%shape_type=shape_types{shape_type_idx};

data_types=get(region_tab_comp.data_type,'string');
data_type_idx=get(region_tab_comp.data_type,'value');
data_type=data_types{data_type_idx};

tag=get(region_tab_comp.tag,'string');

refs=get(region_tab_comp.tog_ref,'string');
ref_idx=get(region_tab_comp.tog_ref,'value');
ref=refs{ref_idx};

w_units=get(region_tab_comp.cell_w_unit,'string');
w_unit_idx=get(region_tab_comp.cell_w_unit,'value');

if isempty(w_unit_idx)
    w_unit_idx=1;
    set(region_tab_comp.cell_w_unit,'value',1);
end
w_unit=w_units{w_unit_idx};

h_units=get(region_tab_comp.cell_h_unit,'string');
h_unit_idx=get(region_tab_comp.cell_h_unit,'value');
if isempty(h_unit_idx)
    h_unit_idx=1;
    set(region_tab_comp.cell_h_unit,'value',1);
end
h_unit=h_units{h_unit_idx};


range=double(Transceiver.get_transceiver_range());
samples=(1:length(range))';
pings=double(Transceiver.get_transceiver_pings()-Transceiver.get_transceiver_pings(1)+1);

idx_r=find(samples>=nanmin(poly_r)&samples<=nanmax(poly_r));
idx_pings=find(pings>=nanmin(poly_pings)&pings<=nanmax(poly_pings));

MaskReg=poly2mask(poly_pings-nanmin(poly_pings),poly_r-nanmin(poly_r),length(idx_r),length(idx_pings));

if isempty(idx_r)||isempty(idx_pings)
    return;
end


cell_h=str2double(get(region_tab_comp.cell_h,'string'));
cell_w=str2double(get(region_tab_comp.cell_w,'string'));

reg_temp=region_cl(...
    'ID',layer.Transceivers(idx_freq).new_id(),...
    'Tag',tag,...
    'Name','User defined',...
    'Type',data_type,...
    'Idx_pings',idx_pings,...
    'Idx_r',idx_r,...
    'Shape','Polygon',...
    'Reference',ref,...
    'MaskReg',MaskReg,...
    'Cell_w',cell_w,...
    'Cell_w_unit',w_unit,...
    'Cell_h',cell_h,...
    'Cell_h_unit',h_unit);


IDs_out=layer.Transceivers(idx_freq).add_region(reg_temp);
display_regions(main_figure,'both');
curr_disp.Active_reg_ID=IDs_out(end);

setappdata(main_figure,'Layer',layer);

order_stacks_fig(main_figure);


end
