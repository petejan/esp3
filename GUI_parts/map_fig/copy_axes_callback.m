function copy_axes_callback(src,~,main_figure)

obj=gco;
if isa(obj,'matlab.graphics.primitive.Patch')&&strcmp(src.SelectionType,'normal')
    
    
    src.WindowButtonMotionFcn = @wbmcb;
    src.WindowButtonUpFcn = @wbucb;
    cp = src.CurrentPoint;
    src.Pointer = 'fleur';
    
end

    function wbmcb(~,~)
        cp = src.CurrentPoint;
    end

    function wbucb(~,~)
        
        if nansum(cp<0|cp>1)>=1
            h=figure();
            ax_old=obj.Parent;
            fig_old=ax_old.Parent;
            new_ax=copyobj(ax_old,h);
            set(new_ax,'Units','Normalized','OuterPosition',[0 0 1 1]);
            set(h,'Name',fig_old.Name,'NumberTitle',fig_old.NumberTitle,'Tag',fig_old.Tag);
        end

        src.Pointer = 'arrow';
        src.WindowButtonMotionFcn = '';
        src.WindowButtonUpFcn = '';
        
        if nargin>=2
            hfigs=getappdata(main_figure,'ExternalFigures');
            setappdata(main_figure,'ExternalFigures',[h hfigs]);
        end
    end

end

