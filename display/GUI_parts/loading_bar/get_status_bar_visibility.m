function vis=get_status_bar_visibility(main_figure)
vis=0;
if~isempty(main_figure)
    jFrame = get(main_figure,'JavaFrame');
    jRootPane = jFrame.fHG2Client.getWindow;
    
    vis=get(jRootPane,'StatusBarVisible');
        
end
end