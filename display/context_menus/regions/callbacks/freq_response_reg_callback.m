
function freq_response_reg_callback(src,evt,select_plot,main_figure,field)

switch class(select_plot)
    case 'region_cl'
        reg_obj=select_plot;
    otherwise
        idx_pings=round(nanmin(select_plot.XData)):round(nanmax(select_plot.XData));
        idx_r=round(nanmin(select_plot.YData)):round(nanmax(select_plot.YData));
        
        reg_obj=region_cl('Name','Select Area','Idx_r',idx_r,'Idx_pings',idx_pings,'Unique_ID','1');
end



switch(field)
    case {'sp','spdenoised','spunmatched'}
        TS_freq_response_func(main_figure,reg_obj)
    case {'sv','svdenoised'}
        Sv_freq_response_func(main_figure,reg_obj)
    otherwise
        TS_freq_response_func(main_figure,reg_obj)
end


end