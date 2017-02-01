function move_mini_axis_grab(src,~,main_figure)

mini_axes_comp=getappdata(main_figure,'Mini_axes');
ah=mini_axes_comp.mini_ax;

current_fig=gcf;

if strcmp(current_fig.SelectionType,'normal')
    cp = current_fig.CurrentPoint;
    current_fig.Pointer = 'fleur';
    pos = getpixelposition(current_fig);

    current_fig.WindowButtonMotionFcn = @wbmcb;
    current_fig.WindowButtonUpFcn = @wbucb;
end
    function wbmcb(~,~)
        cp = current_fig.CurrentPoint;
    end

    function wbucb(~,~)
        current_fig.Pointer = 'arrow';
        current_fig.WindowButtonMotionFcn = '';
        current_fig.WindowButtonUpFcn = '';
        
       if nansum(cp(:)<0)||nansum(cp>pos(3:4))
           undock_mini_axes_callback(src,[],main_figure,'out_figure')
       end
    end
end


