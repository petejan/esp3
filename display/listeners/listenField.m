function listenField(~,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
update_axis_panel(main_figure,0);
update_mini_ax(main_figure);
curr_disp.setTypeCax();load_info_panel(main_figure);
display_info_ButtonMotionFcn([],[],main_figure,1);

end