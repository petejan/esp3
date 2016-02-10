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
if isempty(w_unit_idx)
    w_unit_idx=1;
end
w_unit=w_units{w_unit_idx};



h_units=get(region_tab_comp.cell_h_unit,'string');
h_unit_idx=get(region_tab_comp.cell_h_unit,'value');
if isempty(h_unit_idx)
    h_unit_idx=1;
end
h_unit=h_units{h_unit_idx};


val=str2double(get(src,'string'));
if ~isnan(val)&&val>0
    
    switch get(src,'tag')
        case 'w'
            switch w_unit
                case 'pings'
                    if val>nb_pings
                        val=floor(nb_pings);
                    end
                case 'meters'
                    if val>dist(end)
                        val=floor(dist(end));
                    end
            end
        case 'h'
            switch h_unit
                case 'samples'
                    if val>nb_samples
                        val=floor(nb_samples);
                    end
                    
                case 'meters'
                    if val>layer.Transceivers(idx_freq).Data.Range(end)
                        val=layer.Transceivers(idx_freq).Data.Range(end);
                    end
            end
    end
    set(src,'string',num2str(val,'%.0f'));
else
    set(src,'string',5);
end


end