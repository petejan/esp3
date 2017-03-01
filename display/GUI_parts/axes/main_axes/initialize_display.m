function initialize_display(main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
opt_panel=uitabgroup(main_figure,'Position',[0 .7 0.5 .3],'tag','option_tab_panel');
algo_panel=uitabgroup(main_figure,'Position',[0.5 .7 0.5 .3],'tag','algo_tab_panel');

create_menu(main_figure);
load_cursor_tool(main_figure);
toolbar_obj=findobj(main_figure,'Tag','toolbar_esp3');
toolbar_obj_enable=findobj(toolbar_obj,'Enable','on');
set(toolbar_obj_enable,'Enable','off');
load_display_tab(main_figure,opt_panel);
display_tab_comp=getappdata(main_figure,'Display_tab');

load_mini_axes(main_figure,display_tab_comp.display_tab,[0 0 0.85 0.50]);
load_regions_tab(main_figure,opt_panel);
load_lines_tab(main_figure,opt_panel);
load_calibration_tab(main_figure,opt_panel);
load_processing_tab(main_figure,opt_panel);
load_bottom_tab(main_figure,algo_panel);
load_bottom_tab_v2(main_figure,algo_panel);
load_bad_pings_tab(main_figure,algo_panel);
load_denoise_tab(main_figure,algo_panel);
load_school_detect_tab(main_figure,algo_panel);
load_single_target_tab(main_figure,algo_panel);
load_track_target_tab(main_figure,algo_panel);
load_axis_panel(main_figure);


format_color_gui(main_figure,curr_disp.Font);

set(main_figure,'Visible','on');
drawnow;
movegui(main_figure,'center');
load_loading_bar(main_figure);
load_info_panel(main_figure);
set(main_figure,'Pointer','arrow');

% Initialize Mouse interactions in the figure 
set(main_figure,'WindowButtonDownFcn',@(src,envdata)select_area_cback(src,envdata,main_figure));

% Initialize Keyboard interactions in the figure 
set(main_figure,'KeyPressFcn',{@keyboard_func,main_figure});

%Set wheel mouse scroll cback 
set(main_figure,'WindowScrollWheelFcn',{@scroll_fcn_callback,main_figure});

size_max = get(0, 'MonitorPositions');

try
    javaFrame = get(main_figure,'JavaFrame');
    % Set minimum size of the figure 
    jProx = javaFrame.fHG2Client.getWindow;
    jProx.setMinimumSize(java.awt.Dimension(size_max(1,3)/4*3,size_max(1,4)/4*3));
    setappdata(main_figure,'javaWindow',jProx);
    %jFrame.setMaximized(true);
    
    % Create drag and drop for the figure object 
    jObj = javaFrame.getFigurePanelContainer();
    dndcontrol.initJava();
    dndobj = dndcontrol(jObj);
    % Set Drop callback functions
    dndobj.DropFileFcn = @fileDropFcn;
    dndobj.DropStringFcn = '';
    setappdata(main_figure,'Dndobj',dndobj);
catch err
    disp(err.message);
end

% nested function for above dndobj
    function fileDropFcn(~,evt)
        open_dropped_file(evt,main_figure);
    end

end



