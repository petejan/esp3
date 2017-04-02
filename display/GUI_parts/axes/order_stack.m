%% order_stack.m
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
% * |echo_ax|: TODO: write description and info on variable
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
% * 2017-04-02: header (Alex Schimel).
% * YYYY-MM-DD: first version (Yoann Ladroit). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function order_stack(echo_ax)

echo_im=findobj(echo_ax,'tag','echo');
bt_im=findobj(echo_ax,'tag','bad_transmits');
lines=findobj(echo_ax,'Type','Line','-not','tag','region','-not','tag','region_cont');
text_disp=findobj(echo_ax,'Type','Text');
regions_cont=findobj(echo_ax,'tag','region_cont','-and','visible','on');
regions=findobj(echo_ax,'tag','region','-and','visible','on');
%region_text=findobj(echo_ax,'tag','region_text','-and','visible','on');
select_area=findobj(echo_ax,'tag','SelectArea');

zoom_area=findobj(echo_ax,'tag','zoom_area');

switch echo_ax.Tag
    case 'main'
        uistack([zoom_area;text_disp;lines;select_area;regions;regions_cont;bt_im;echo_im],'top');
    case 'mini'
        uistack([zoom_area;bt_im;text_disp;lines;select_area;regions;regions_cont;echo_im],'top');
end
echo_ax.Layer='top';
end