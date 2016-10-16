function load_loading_bar(main_figure)

if isappdata(main_figure,'Loading_bar')
    load_bar_comp=getappdata(main_figure,'Loading_bar');
    delete(load_bar_comp);
    rmappdata(main_figure,'Loading_bar');
end


jFrame = get(main_figure,'JavaFrame');
jRootPane = jFrame.fHG2Client.getWindow;
load_bar_comp.status_bar = com.mathworks.mwswing.MJStatusBar;

% Add a progress-bar to left side of standard MJStatusBar container
load_bar_comp.progress_bar = javax.swing.JProgressBar;
set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',100, 'Value',0, 'StringPainted',1);
load_bar_comp.status_bar.add(load_bar_comp.progress_bar,'West'); 

jRootPane.setStatusBar(load_bar_comp.status_bar);

load_bar_comp.status_bar.setText('');
load_bar_comp.status_bar.setVisible(1);
jRootPane.setStatusBarVisible(1);
setappdata(main_figure,'Loading_bar',load_bar_comp);

end
