function shift_bottom_callback(~,~,select_plot,main_figure)
    
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
idx_pings=round(nanmin(select_plot.XData)):round(nanmax(select_plot.XData));


answer=inputdlg('Enter Shifting value','Shift Bottom',1,{'0'});

if isempty(answer)||isnan(str2double(answer{1}))
    return;
end

layer.Transceivers(idx_freq).shift_bottom(str2double(answer{1}),idx_pings);


curr_disp.Bot_changed_flag=1; 

setappdata(main_figure,'Curr_disp',curr_disp);
setappdata(main_figure,'Layer',layer);
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
display_bottom(main_figure);
order_stacks_fig(main_figure);

end