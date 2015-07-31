function update_processing_tab(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
processing_tab_comp=getappdata(main_figure,'Processing_tab');
process_list=getappdata(main_figure,'Process');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

set(processing_tab_comp.tog_freq,'String',layer.Frequencies,'Value',idx_freq);

if ~isempty(process_list)
    [~,~,found]=find_process_algo(process_list,curr_disp.Freq,'Denoise');
    noise_rem_algo=found;
    [~,~,found]=find_process_algo(process_list,curr_disp.Freq,'BottomDetection');
    bot_algo=found;
    [~,~,found]=find_process_algo(process_list,curr_disp.Freq,'BadPings');
    bad_trans_algo=found;
    [~,~,found]=find_process_algo(process_list,curr_disp.Freq,'SchoolDetection');
    school_detect_algo=found;
else
    
    noise_rem_algo=0;
    
    bot_algo=0;
    
    bad_trans_algo=0;
    
    school_detect_algo=0;
    
end

set(processing_tab_comp.noise_removal,'Value',noise_rem_algo);
set(processing_tab_comp.bot_detec,'Value',bot_algo);
set(processing_tab_comp.bad_transmit,'Value',bad_trans_algo);
set(processing_tab_comp.school_detec,'Value',school_detect_algo);

setappdata(main_figure,'Curr_disp',curr_disp);

end