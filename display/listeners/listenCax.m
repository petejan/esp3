function listenCax(~,~,main_figure)
set(main_figure,'KeyPressFcn','');
update_display_tab(main_figure);
set_alpha_map(main_figure,'main_or_min','mini');
set_alpha_map(main_figure);
set(main_figure,'KeyPressFcn',{@keyboard_func,main_figure});
end