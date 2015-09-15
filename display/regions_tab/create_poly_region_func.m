
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

refs=get(region_tab_comp.tog_ref,'string');
ref_idx=get(region_tab_comp.tog_ref,'value');
ref=refs{ref_idx};

w_units=get(region_tab_comp.cell_w_unit,'string');
w_unit_idx=get(region_tab_comp.cell_w_unit,'value');
w_unit=w_units{w_unit_idx};

h_units=get(region_tab_comp.cell_h_unit,'string');
h_unit_idx=get(region_tab_comp.cell_h_unit,'value');
h_unit=h_units{h_unit_idx};


range=double(Transceiver.Data.Range);
samples=(1:length(range))';
pings=double(Transceiver.Data.Number-Transceiver.Data.Number(1)+1);

idx_r=find(samples>=nanmin(poly_r)&samples<=nanmax(poly_r));
idx_pings=find(pings>=nanmin(poly_pings)&pings<=nanmax(poly_pings));


Sv=layer.Transceivers(idx_freq).Data.get_datamat('Sv');
Sv(~poly2mask(poly_pings,poly_r,length(samples),length(pings)))=nan;

Sv_reg=Sv(idx_r,idx_pings);

if isempty(idx_r)||isempty(idx_pings)
    return;
end


cell_h=str2double(get(region_tab_comp.cell_h,'string'));
cell_w=str2double(get(region_tab_comp.cell_w,'string'));

reg_temp=region_cl(...
    'ID',new_id(layer.Transceivers(idx_freq),'User defined'),...
    'Name','User defined',...
    'Type',data_type,...
    'Idx_pings',idx_pings,...
     'Idx_r',idx_r,...
    'Shape','Polygon',...
    'Reference',ref,...
    'Sv_reg',Sv_reg,...
    'Cell_w',cell_w,...
    'Cell_w_unit',w_unit,...
    'Cell_h',cell_h,...
    'Cell_h_unit',h_unit,...
    'Output',[]);

%         figure();
%         hold on;
%         plot(10*log10(nanmean(10.^(reg_temp.Output.Sv_mean'/10))),nanmean(reg_temp.Output.y_node'));
%         grid on;
%         xlabel('Sv mean')
%         ylabel(sprintf('Depth (%s)',h_unit));
%         axis ij;

layer.Transceivers(idx_freq).add_region(reg_temp);

list_reg = list_regions(layer.Transceivers(idx_freq));

if ~isempty(list_reg)
    set(region_tab_comp.tog_reg,'string',list_reg);
    set(region_tab_comp.tog_reg,'value',length(list_reg));
else
    set(region_tab_comp.tog_reg,'string',{'--'});
end
setappdata(main_figure,'Region_tab',region_tab_comp);
setappdata(main_figure,'Layer',layer);
load_axis_panel(main_figure,0)
end
