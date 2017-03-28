%% copy_axes_callback.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |src|: TODO: write description and info on variable
% * |main_figure|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function copy_axes_callback(src,~,main_figure)

obj=gco;
if isa(obj,'matlab.graphics.primitive.Patch')&&strcmp(src.SelectionType,'normal')
    
    wbucb_ori=src.WindowButtonUpFcn;
    wbmcb_ori=src.WindowButtonMotionFcn;
    
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
        src.WindowButtonMotionFcn = wbmcb_ori;
        src.WindowButtonUpFcn = wbucb_ori;

    end

end

