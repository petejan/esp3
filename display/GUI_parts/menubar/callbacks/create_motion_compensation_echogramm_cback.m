function create_motion_compensation_echogramm_cback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
create_motion_comp_subdata(layer,idx_freq,1);

curr_disp.setField('motioncompensation');
setappdata(main_figure,'Curr_disp',curr_disp);

end