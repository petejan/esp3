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


