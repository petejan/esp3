function listenCax(~,~,main_figure)
replace_interaction(main_figure,'interaction','WindowKeyPressFcn','id',1);
update_display_tab(main_figure);
set_alpha_map(main_figure,'main_or_min','mini');
set_alpha_map(main_figure);
replace_interaction(main_figure,'interaction','WindowKeyPressFcn','id',1,'interaction_fcn',{@keyboard_func,main_figure});
end