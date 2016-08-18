function move_mini_axis_grab(~,~,main_figure)

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
        
       if nansum(cp(1,1:2)<0|cp(1:2>pos(3:4))>=1)
           size_max = get(0, 'MonitorPositions');
%            if size(size_max,1)==1
%                pos_out=[size_max(2,1) size_max(2,2)+size_max(2,4)*0.2 size_max(2,3) size_max(2,4)*0.5];
%            else
               pos_out=[size_max(1,1) size_max(1,2)+size_max(1,4)*0.2 size_max(1,3) size_max(1,4)*0.5];
%            end
           h=figure('units','pixels','position',pos_out,...
               'Color','White',...                                         %Background color
               'Name','Overview','NumberTitle','off',...    %GUI Name
               'Resize','on',...
               'MenuBar','none',...'%No Matlab Menu
               'CloseRequestFcn',{@close_min_axis,main_figure},...
               'WindowScrollWheelFcn',{@scroll_fcn_callback,main_figure},...
               'KeyPressFcn',{@keyboard_func,main_figure});
            load_mini_axes(main_figure,h,[0 0 1 1]);
            update_mini_ax(main_figure);
            update_cmap(main_figure)
        else  
            h=[];
        end
        
        current_fig.Pointer = 'arrow';
        current_fig.WindowButtonMotionFcn = '';
        current_fig.WindowButtonUpFcn = '';
        
        if nargin>2
            hfigs=getappdata(main_figure,'ExternalFigures');
            setappdata(main_figure,'ExternalFigures',[h hfigs]);
        end
    end
end


