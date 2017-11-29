
function freq_response_reg_callback(src,evt,select_plot,main_figure,field)
layer=getappdata(main_figure,'Layer');

switch class(select_plot)
    case 'region_cl'
        curr_disp=getappdata(main_figure,'Curr_disp');
       
        [trans_obj,~]=layer.get_trans(curr_disp);

        reg_obj=trans_obj.get_region_from_Unique_ID(curr_disp.Active_reg_ID);
    otherwise
        idx_pings=round(nanmin(select_plot.XData)):round(nanmax(select_plot.XData));
        idx_r=round(nanmin(select_plot.YData)):round(nanmax(select_plot.YData));        
        reg_obj=region_cl('Name','Select Area','Idx_r',idx_r,'Idx_pings',idx_pings,'Unique_ID','1');
end




for i=1:length(reg_obj)
    
    if~isempty(layer.Curves)
        layer.Curves(cellfun(@(x) strcmp(x,reg_obj(i).Unique_ID),{layer.Curves(:).Unique_ID}))=[];
    end
    
    switch(field)
        case {'sp','spdenoised','spunmatched'}
            update_multi_freq_disp_tab(main_figure,'ts_f',0);
            TS_freq_response_func(main_figure,reg_obj(i));
            update_multi_freq_disp_tab(main_figure,'ts_f',0);
        case {'sv','svdenoised'}
            update_multi_freq_disp_tab(main_figure,'sv_f',0);
            Sv_freq_response_func(main_figure,reg_obj(i));
            update_multi_freq_disp_tab(main_figure,'sv_f',0);
        otherwise
            update_multi_freq_disp_tab(main_figure,'ts_f',0);
            TS_freq_response_func(main_figure,reg_obj(i));
            update_multi_freq_disp_tab(main_figure,'ts_f',0);
    end
end

end