%% move_mini_axis_grab.m
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
function move_mini_axis_grab(src,~,main_figure)

current_fig=gcf;

ptr=current_fig.Pointer;
if strcmp(current_fig.SelectionType,'normal')
    cp = current_fig.CurrentPoint;

    pos = getpixelposition(current_fig);

    replace_interaction(current_fig,'interaction','WindowButtonMotionFcn','id',2,'interaction_fcn',@wbmcb,'Pointer','fleur');
    replace_interaction(current_fig,'interaction','WindowButtonUpFcn','id',2,'interaction_fcn',@wbucb);

end
    function wbmcb(~,~)
        cp = current_fig.CurrentPoint;
    end

    function wbucb(~,~)

        replace_interaction(current_fig,'interaction','WindowButtonMotionFcn','id',2,'Pointer',ptr);
        replace_interaction(current_fig,'interaction','WindowButtonUpFcn','id',2);
        
       if nansum(cp(:)<0)||nansum(cp>pos(3:4))
           undock_mini_axes_callback(src,[],main_figure,'out_figure')
       end
    end
end


