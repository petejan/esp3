%% undock_reglist_tab_callback.m
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
% * |main_figure|: TODO: write description and info on variable
% * |dest|: TODO: write description and info on variable
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
% * 2017-03-28: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function undock_reglist_tab_callback(~,~,main_figure,dest)

layer=getappdata(main_figure,'Layer');
if isempty(layer);
    return;
end
reglist_tab_comp=getappdata(main_figure,'Reglist_tab');

switch dest
    case 'main_figure'
        delete(reglist_tab_comp.reglist_tab);
        dest_fig=getappdata(main_figure,'option_tab_panel');
    otherwise
        delete(reglist_tab_comp.reglist_tab);
        size_max = get(0, 'MonitorPositions');
        pos_fig=[size_max(1,1)+size_max(1,3)*0.3 size_max(1,2)+size_max(1,4)*0.4 size_max(1,3)*0.4 size_max(1,4)*0.2];
        dest_fig=new_echo_figure(main_figure,...
            'Units','pixels',...
            'Position',pos_fig,...
            'Name','Regions List',...
            'Resize','on',...
            'CloseRequestFcn',@close_reglist_tab,...
            'Tag','reglist_tab');
end

 load_reglist_tab(main_figure,dest_fig);

end

function close_reglist_tab(src,~,main_figure)
undock_reglist_tab_callback(src,[],main_figure,'main_figure');
end