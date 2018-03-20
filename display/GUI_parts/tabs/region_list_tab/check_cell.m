function check_cell(src,~,main_figure,reglist_tab_comp)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

[trans_obj,~]=layer.get_trans(curr_disp);
dist=trans_obj.GPSDataPing.Dist;
time=trans_obj.get_transceiver_time();
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
                        val=dist(end);
                    end
                     fmt='%.1f';
                case 'seconds'
                     fmt='%.1f';
                     if val>(time(end)-time(1))*24*60*60
                         val=(time(end)-time(1))*24*60*60;
                     end
            end
        case 'h'
            switch h_unit
                case 'samples'
                    if val>nb_samples
                        val=floor(nb_samples);
                    end
                     fmt='%.0f';
                case 'meters'
                    
                    if val>range(end)
                        val=range(end);
                    end
                     fmt='%.1f';
            end
    end
    set(src,'string',num2str(val,fmt));
else
    set(src,'string',5);
end


end