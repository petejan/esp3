function listenFont(~,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
hfigs=getappdata(main_figure,'ExternalFigures');
format_color_gui(union(hfigs,main_figure),curr_disp.Font);
%format_color_gui(main_figure,curr_disp.Font);
end
