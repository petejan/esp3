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
    [~,~,found]=find_process_algo(process_list,curr_disp.Freq,'BottomDetectionV2');
    bot_algo=found;
    [~,~,found]=find_process_algo(process_list,curr_disp.Freq,'BadPings');
    bad_trans_algo=found;
    [~,~,found]=find_process_algo(process_list,curr_disp.Freq,'SchoolDetection');
    school_detect_algo=found;
    [~,~,found]=find_process_algo(process_list,curr_disp.Freq,'SingleTarget');
    single_target_alg=found;
    [~,~,found]=find_process_algo(process_list,curr_disp.Freq,'TrackTarget');
    track_target_alg=found;
else
    
    noise_rem_algo=0;
    
    bot_algo=0;
    
    bad_trans_algo=0;
    
    school_detect_algo=0;
    
    single_target_alg=0;
    
    track_target_alg=0;
end

set(processing_tab_comp.noise_removal,'Value',noise_rem_algo);
set(processing_tab_comp.bot_detec,'Value',bot_algo);
set(processing_tab_comp.bad_transmit,'Value',bad_trans_algo);
set(processing_tab_comp.school_detec,'Value',school_detect_algo);
set(processing_tab_comp.single_target,'Value',single_target_alg);
set(processing_tab_comp.track_target,'Value',track_target_alg);

%set(findall(processing_tab_comp.processing_tab, '-property', 'Enable'), 'Enable', 'on');

setappdata(main_figure,'Processing_tab',processing_tab_comp);

end