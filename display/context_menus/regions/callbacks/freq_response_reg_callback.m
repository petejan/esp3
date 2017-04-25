
function freq_response_reg_callback(~,~,main_figure,field)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');


region_tab_comp=getappdata(main_figure,'Region_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
Transceiver=layer.Transceivers(idx_freq);
list_reg = layer.Transceivers(idx_freq).regions_to_str();

if ~isempty(list_reg)
    active_reg=Transceiver.Regions(get(region_tab_comp.tog_reg,'value'));
    
    idx_pings=active_reg.Idx_pings;
    idx_r=active_reg.Idx_r;
    
    switch(field)
        case {'sp','spdenoised','spunmatched'}
            TS_freq_response_func(main_figure,idx_r,idx_pings)
        case {'sv','svdenoised'}   
            Sv_freq_response_func(main_figure,idx_r,idx_pings)
        otherwise
            TS_freq_response_func(main_figure,idx_r,idx_pings)
    end
end


end