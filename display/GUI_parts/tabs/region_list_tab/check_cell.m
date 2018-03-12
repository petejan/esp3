function check_cell(src,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
reglist_tab_comp=getappdata(main_figure,'Reglist_tab');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);
dist=trans_obj.GPSDataPing.Dist;

nb_pings=length(trans_obj.get_transceiver_pings());
nb_samples=length(trans_obj.get_transceiver_range());

w_units=get(reglist_tab_comp.cell_w_unit,'string');
w_unit_idx=get(reglist_tab_comp.cell_w_unit,'value');
if isempty(w_unit_idx)
    w_unit_idx=1;
end
w_unit=w_units{w_unit_idx};



h_units=get(reglist_tab_comp.cell_h_unit,'string');
h_unit_idx=get(reglist_tab_comp.cell_h_unit,'value');
if isempty(h_unit_idx)
    h_unit_idx=1;
end
h_unit=h_units{h_unit_idx};

 range=trans_obj.get_transceiver_range();
val=str2double(get(src,'string'));
if ~isnan(val)&&val>0
    
    switch get(src,'tag')
        case 'w'
            switch w_unit
                case 'pings'
                    if val>nb_pings
                        val=floor(nb_pings);
                    end
                    fmt='%.0f';
                case 'meters'
                    if val>dist(end)
                        val=floor(dist(end));
                    end
                     fmt='%.2f';
            end
        case 'h'
            switch h_unit
                case 'samples'
                    if val>nb_samples
                        val=floor(nb_samples);
                    end
                     fmt='%.0f';
                case 'meters'
                    
                    if val>range(end);
                        val=range(end);
                    end
                     fmt='%.2f';
            end
    end
    set(src,'string',num2str(val,fmt));
else
    set(src,'string',5);
end


end