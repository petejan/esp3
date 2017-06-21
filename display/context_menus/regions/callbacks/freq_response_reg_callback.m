
function freq_response_reg_callback(src,evt,select_plot,main_figure,field)

switch class(select_plot)
    case 'region_cl'
        idx_r=select_plot.Idx_r;
        idx_pings=select_plot.Idx_pings;       
    otherwise
        idx_pings=round(nanmin(select_plot.XData)):round(nanmax(select_plot.XData));
        idx_r=round(nanmin(select_plot.YData)):round(nanmax(select_plot.YData));
end



switch(field)
    case {'sp','spdenoised','spunmatched'}
        TS_freq_response_func(main_figure,idx_r,idx_pings)
    case {'sv','svdenoised'}
        Sv_freq_response_func(main_figure,idx_r,idx_pings)
    otherwise
        TS_freq_response_func(main_figure,idx_r,idx_pings)
end


end