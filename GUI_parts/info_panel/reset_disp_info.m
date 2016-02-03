function reset_disp_info(main_figure)

set(main_figure,'WindowButtonMotionFcn',{@display_info_ButtonMotionFcn,main_figure,0});

end