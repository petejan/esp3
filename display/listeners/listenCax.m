function listenCax(~,~,main_figure)
replace_interaction(main_figure,'interaction','KeyPressFcn','id',1);
update_display_tab(main_figure);
set_alpha_map(main_figure,'main_or_min','mini');
set_alpha_map(main_figure);
curr_disp=getappdata(main_figure,'Curr_disp');
single_target_tab_comp=getappdata(main_figure,'Single_target_tab');
cax=curr_disp.getCaxField('singletarget');
caxis(single_target_tab_comp.ax_pos,cax);

replace_interaction(main_figure,'interaction','KeyPressFcn','id',1,'interaction_fcn',{@keyboard_func,main_figure});
end