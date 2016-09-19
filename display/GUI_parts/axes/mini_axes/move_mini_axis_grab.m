function move_mini_axis_grab(src,~,main_figure)

mini_axes_comp=getappdata(main_figure,'Mini_axes');
ah=mini_axes_comp.mini_ax;

current_fig=gcf;

if strcmp(current_fig.SelectionType,'normal')
    cp = ah.CurrentPoint;
    current_fig.Pointer = 'fleur';
    set(current_fig,'units','normalized');
    pos=ah.Position;
    set(current_fig,'units','pixels');
    current_fig.WindowButtonMotionFcn = @wbmcb;
    current_fig.WindowButtonUpFcn = @wbucb;
end
    function wbmcb(~,~)
        cp = ah.CurrentPoint;
    end

    function wbucb(~,~)
        current_fig.Pointer = 'arrow';
        current_fig.WindowButtonMotionFcn = '';
        current_fig.WindowButtonUpFcn = '';
        
       if nansum(cp(1,1:2)<0|cp(1:2>pos(3:4))>=1)
           undock_mini_axes_callback(src,[],main_figure)
       end
    end
end


