%% tog_units.m
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
function tog_units(src,~,main_figure,reglist_tab_comp)


w_units=get(reglist_tab_comp.cell_w_unit,'string');
w_unit_idx=get(reglist_tab_comp.cell_w_unit,'value');
w_unit=w_units{w_unit_idx};

h_units=get(reglist_tab_comp.cell_h_unit,'string');
h_unit_idx=get(reglist_tab_comp.cell_h_unit,'value');
h_unit=h_units{h_unit_idx};

switch get(src,'tag')
    case 'w'
        if reglist_tab_comp.cell_w_unit_curr==w_unit_idx
            return;
        end
        val=str2double(get(reglist_tab_comp.cell_w,'string'));
        switch w_unit
            case 'pings'
                set(reglist_tab_comp.cell_w,'string',num2str(val,'%.0f'));
            case 'meters'
                set(reglist_tab_comp.cell_w,'string',num2str(val,'%.2f'));       
            case 'seconds'
                set(reglist_tab_comp.cell_w,'string',num2str(val,'%.1f'));  
        end
        reglist_tab_comp.cell_w_unit_curr=w_unit_idx;
        
    case 'h'
        if reglist_tab_comp.cell_h_unit_curr==h_unit_idx
            return;
        end
        val=str2double(get(reglist_tab_comp.cell_h,'string'));
        switch h_unit
            case 'samples'
                set(reglist_tab_comp.cell_h,'string',num2str(val,'%.0f'));
            case 'meters'
                set(reglist_tab_comp.cell_h,'string',num2str(val,'%.2f'));

        end
        reglist_tab_comp.cell_h_unit_curr=h_unit_idx;
        
end
end
