function tog_reg_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
region_tab_comp=getappdata(main_figure,'Region_tab');
curr_disp=getappdata(main_figure,'Curr_disp');

idx_freq=find_freq_idx(layer,curr_disp.Freq);

active_reg=get(region_tab_comp.tog_reg,'value');
list_name=get(region_tab_comp.tog_reg,'string');

switch list_name{active_reg}
    case '--'
        return
    otherwise
        reg_curr=layer.Transceivers(idx_freq).Regions(active_reg);
end
shape_types=get(region_tab_comp.shape_type,'string');
shape_type_idx=find(strcmp(reg_curr.Shape,shape_types));
set(region_tab_comp.shape_type,'value',shape_type_idx);

data_types=get(region_tab_comp.data_type,'string');
data_type_idx=find(strcmp(reg_curr.Type,data_types));
set(region_tab_comp.data_type,'value',data_type_idx);

refs=get(region_tab_comp.tog_ref,'string');
ref_idx=find(strcmp(reg_curr.Reference,refs));
set(region_tab_comp.tog_ref,'value',ref_idx);

w_units=get(region_tab_comp.cell_w_unit,'string');
w_unit_idx=find(strcmp(reg_curr.Cell_w_unit,w_units));
set(region_tab_comp.cell_w_unit,'value',w_unit_idx);

h_units=get(region_tab_comp.cell_h_unit,'string');
h_unit_idx=find(strcmp(reg_curr.Cell_h_unit,h_units));
set(region_tab_comp.cell_h_unit,'value',h_unit_idx);

cell_w=reg_curr.Cell_w;
set(region_tab_comp.cell_w,'string',cell_w);

cell_h=reg_curr.Cell_h;
set(region_tab_comp.cell_h,'string',cell_h);

display_regions(main_figure)
end

function check_cell(src,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
region_tab_comp=getappdata(main_figure,'Region_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
dist=layer.Transceivers(idx_freq).GPSDataPing.Dist;

nb_pings=length(layer.Transceivers(idx_freq).Data.Number);
nb_samples=length(layer.Transceivers(idx_freq).Data.Range);

w_units=get(region_tab_comp.cell_w_unit,'string');
w_unit_idx=get(region_tab_comp.cell_w_unit,'value');
w_unit=w_units{w_unit_idx};

h_units=get(region_tab_comp.cell_h_unit,'string');
h_unit_idx=get(region_tab_comp.cell_h_unit,'value');
h_unit=h_units{h_unit_idx};


val=str2double(get(src,'string'));
if ~isnan(val)&&val>0
    
    switch get(src,'tag')
        case 'w'
            switch w_unit
                case 'pings'
                    if val>nb_pings/2
                        val=floor(nb_pings/2);
                    end
                case 'meters'
                    if val>dist(end)/2
                        val=floor(dist(end)/2);
                    end
            end
        case 'h'
            switch h_unit
                case 'samples'
                    if val>nb_samples/2
                        val=floor(nb_samples);
                    end
                    
                case 'meters'
                    if val>layer.Transceivers(idx_freq).Data.Range(end)/2
                        val=layer.Transceivers(idx_freq).Data.Range(end)/2;
                    end
            end
    end
    set(src,'string',num2str(val,'%.0f'));
else
    set(src,'string',5);
end


end