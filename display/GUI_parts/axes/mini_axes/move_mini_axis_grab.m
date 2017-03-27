function move_mini_axis_grab(src,~,main_figure)


current_fig=gcf;
wbmf_ori=get(current_fig,'WindowButtonMotionFcn');
wbuf_ori=get(current_fig,'WindowButtonUpFcn');


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
        current_fig.WindowButtonMotionFcn = wbmf_ori;
        current_fig.WindowButtonUpFcn = wbuf_ori;
        
       if nansum(cp(:)<0)||nansum(cp>pos(3:4))
           undock_mini_axes_callback(src,[],main_figure,'out_figure')
       end
    end
end


