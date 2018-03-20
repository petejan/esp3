function change_axes_ratio_cback(src,evt_data,main_figure,hov)
curr_disp=getappdata(main_figure,'Curr_disp');

if ~strcmpi(curr_disp.CursorMode,'normal')
    return;
end

axes_panel_comp=getappdata(main_figure,'Axes_panel');
axes_panel_comp.axes_panel;
switch main_figure.SelectionType
    case 'normal'
        
        pos_panel=getpixelposition(axes_panel_comp.axes_panel,true);
        pos_ax=getpixelposition(src,true);
        cp = main_figure.CurrentPoint;
        x1 = cp(1,1)-pos_ax(1);
        y1 = pos_panel(2)+pos_panel(4)-cp(1,2);
        switch(hov)
            case 'h'
                ptr='top';
            case 'v'
                ptr='left';
        end
        
        replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2,'interaction_fcn',@wbmcb,'Pointer',ptr);
        replace_interaction(main_figure,'interaction','WindowButtonUpFcn','id',2,'interaction_fcn',@wbucb,'Pointer',ptr);
    case 'open'
        
        switch(hov)
            case 'h'
                if curr_disp.H_axes_ratio==0
                    curr_disp.H_axes_ratio=0.1;
                else
                    curr_disp.H_axes_ratio=0;
                end
            case 'v'
                if curr_disp.V_axes_ratio==0
                    curr_disp.V_axes_ratio=0.05;
                else
                    curr_disp.V_axes_ratio=0;
                end
        end
end
    function wbmcb(~,~)
        cp = main_figure.CurrentPoint;
        pos_ax=getpixelposition(src,true);
        x1 = cp(1,1)-pos_ax(1);
        y1 = pos_panel(2)+pos_panel(4)-cp(1,2);
        
        pos_panel(2);
        %y1/pos_panel(4);
        switch(hov)
            case 'h'
                if y1>=-0.1 &&y1<pos_panel(4)/5
                    curr_disp.H_axes_ratio=y1/pos_panel(4);
                end
            case 'v'
                if x1>=-0.1 &&x1<pos_panel(3)/5
                    curr_disp.V_axes_ratio=x1/pos_panel(3);
                end
        end
    end

    function wbucb(~,~)
        replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2);
        replace_interaction(main_figure,'interaction','WindowButtonUpFcn','id',2);
    end

end



