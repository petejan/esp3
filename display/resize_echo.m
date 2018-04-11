
function resize_echo(main_figure,~)

pix_pos=getpixelposition(main_figure);
pan_height=get_top_panel_height(6);

echo_tab_panel=getappdata(main_figure,'echo_tab_panel');
opt_panel=getappdata(main_figure,'option_tab_panel');
algo_panel=getappdata(main_figure,'algo_tab_panel');

set(opt_panel,'Position',[0 pix_pos(4)-pan_height 0.5*pix_pos(3) pan_height]);
set(algo_panel,'Position',[0.5*pix_pos(3) pix_pos(4)-pan_height 0.5*pix_pos(3) pan_height]);
set(echo_tab_panel,'Position',[0 0.05*pix_pos(4) pix_pos(3) pix_pos(4)-pan_height-0.05*pix_pos(4)]);

end