function tog_units(src,~,main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
region_tab_comp=getappdata(main_figure,'Region_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
dist=layer.Transceivers(idx_freq).GPSDataPing.Dist;
dx=nanmean(diff(dist));
%pings=length(layer.Transceivers(idx_freq).Data.Number);
range=layer.Transceivers(idx_freq).Data.Range;
dr=nanmean(diff(range));
w_units=get(region_tab_comp.cell_w_unit,'string');
w_unit_idx=get(region_tab_comp.cell_w_unit,'value');
w_unit=w_units{w_unit_idx};

h_units=get(region_tab_comp.cell_h_unit,'string');
h_unit_idx=get(region_tab_comp.cell_h_unit,'value');
h_unit=h_units{h_unit_idx};

switch get(src,'tag')
    case 'w'
        if region_tab_comp.cell_w_unit_curr==w_unit_idx
            return;
        end
        val=str2double(get(region_tab_comp.cell_w,'string'));
        switch w_unit
            case 'pings'
                val=val/dx;
            case 'meters'
                val=val*dx;
                
        end
        region_tab_comp.cell_w_unit_curr=w_unit_idx;
        set(region_tab_comp.cell_w,'string',num2str(val,'%.0f'));
    case 'h'
        if region_tab_comp.cell_h_unit_curr==h_unit_idx
            return;
        end
        val=str2double(get(region_tab_comp.cell_h,'string'));
        switch h_unit
            case 'samples'
                val=val/dr;
            case 'meters'
                val=val*dr;
        end
        region_tab_comp.cell_h_unit_curr=h_unit_idx;
        set(region_tab_comp.cell_h,'string',num2str(val,'%.0f'));
end
setappdata(main_figure,'Region_tab',region_tab_comp);
end
