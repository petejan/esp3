function freq_response(src,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');

switch(curr_disp.Type)
    case 'Sp'   
        inter_region_create(src,main_figure,'rectangular',@TS_freq_response_func);
    case 'Sv'
        inter_region_create(src,main_figure,'rectangular',@Sv_freq_response_func);
end


end