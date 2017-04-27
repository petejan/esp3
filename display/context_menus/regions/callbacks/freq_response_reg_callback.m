
function freq_response_reg_callback(src,evt,reg_curr,main_figure,field)


switch class(reg_curr)
    case 'matlab.graphics.primitive.Patch'
        idx_pings=round(nanmin(reg_curr.XData)):round(nanmax(reg_curr.XData));
        idx_r=round(nanmin(reg_curr.YData)):round(nanmax(reg_curr.YData));

    case 'region_cl'
        idx_r=reg_curr.Idx_r;
        idx_pings=reg_curr.Idx_pings;
    otherwise
        return;
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