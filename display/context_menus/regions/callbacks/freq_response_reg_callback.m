
function freq_response_reg_callback(src,evt,reg_curr,main_figure,field)


idx_r=reg_curr.Idx_r;
idx_pings=reg_curr.Idx_pings;


switch(field)
    case {'sp','spdenoised','spunmatched'}
        TS_freq_response_func(main_figure,idx_r,idx_pings)
    case {'sv','svdenoised'}
        Sv_freq_response_func(main_figure,idx_r,idx_pings)
    otherwise
        TS_freq_response_func(main_figure,idx_r,idx_pings)
end


end