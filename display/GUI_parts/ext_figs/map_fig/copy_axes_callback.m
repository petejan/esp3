function copy_axes_callback(src,~,main_figure)

obj=gco;
if isa(obj,'matlab.graphics.primitive.Patch')&&strcmp(src.SelectionType,'normal')
    
    
    src.WindowButtonMotionFcn = @wbmcb;
    src.WindowButtonUpFcn = @wbucb;
    cp = src.CurrentPoint;
    src.Pointer = 'fleur';
    pos=src.Position;
    
end

    function wbmcb(~,~)
        cp = src.CurrentPoint;
    end

    function wbucb(~,~)
        
        if nansum(cp<0|cp>pos(3:4))>=1
            ax_old=obj.Parent;
            fig_old=ax_old.Parent;
            h=new_echo_figure(main_figure,'Name',[fig_old.Name 'Copy'],'Tag',[fig_old.Tag '_copy']);
            
            new_ax=copyobj(ax_old,h);
            set(new_ax,'Units','Normalized','OuterPosition',[0 0 1 1]);


        end
        
        src.Pointer = 'arrow';
        src.WindowButtonMotionFcn = '';
        src.WindowButtonUpFcn = '';

    end

end

