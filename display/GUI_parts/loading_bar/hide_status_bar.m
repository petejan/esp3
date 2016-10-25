function hide_status_bar(main_figure)
% load_bar_comp=getappdata(main_figure,'Loading_bar');
% 
% load_bar_comp.status_bar.setVisible(0);
% load_bar_comp.status_bar.setText('');

jFrame = get(main_figure,'JavaFrame');
jRootPane = jFrame.fHG2Client.getWindow;

jRootPane.setStatusBarVisible(0);

reinit_loading_bar(main_figure);
end