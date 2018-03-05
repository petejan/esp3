function listenCax(~,~,main_figure)
%profile on;
replace_interaction(main_figure,'interaction','KeyPressFcn','id',1);
update_display_tab(main_figure);
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
set_alpha_map(main_figure,'main_or_mini',union({'main','mini'},layer.ChannelID));

map_tab_comp=getappdata(main_figure,'Map_tab');

cax=curr_disp.getCaxField('singletarget');
caxis(map_tab_comp.ax_pos,cax);

cax=curr_disp.getCaxField('singletarget');

xlim(map_tab_comp.ax_hist,cax);
% link_ylim_to_echo_clim([],[],main_figure,'sv_f');
% link_ylim_to_echo_clim([],[],main_figure,'ts_f');
fix_ylim([],[],main_figure,'sv_f');
fix_ylim([],[],main_figure,'ts_f');

replace_interaction(main_figure,'interaction','KeyPressFcn','id',1,'interaction_fcn',{@keyboard_func,main_figure});
% profile off;
% profile viewer;
end