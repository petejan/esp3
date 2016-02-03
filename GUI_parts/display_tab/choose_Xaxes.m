function  choose_Xaxes(obj,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
idx=get(obj,'value');
str=get(obj,'String');
curr_disp.Xaxes=str{idx};
setappdata(main_figure,'Curr_disp',curr_disp);
load_axis_panel(main_figure,0);
change_grid_callback([],[],main_figure);
end