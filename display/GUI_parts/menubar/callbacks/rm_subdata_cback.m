function rm_subdata_cback(~,~,main_figure,field)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
trans_obj=layer.get_trans(curr_disp);

switch field
    case 'denoised'
        fields={'powerdenoised' 'svdenoised' 'snr' 'spdenoised'};
    case 'st'
        trans_obj.ST=init_st_struct();
        trans_obj.Tracks=[];
        fields={'singletarget'};
        if~isempty(layer.Curves)
            layer.Curves(contains({layer.Curves(:).Unique_ID},'track'))=[];
        end
        update_map_tab(main_figure,'st',1,'histo',1);
        update_multi_freq_disp_tab(main_figure,'ts_f',1);
end
    
trans_obj.Data.remove_sub_data(fields);

setappdata(main_figure,'Layer',layer);
display_tracks(main_figure);

curr_disp.setField('sv');

end