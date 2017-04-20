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
function tog_units(src,~,main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
region_tab_comp=getappdata(main_figure,'Region_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
dist=layer.Transceivers(idx_freq).GPSDataPing.Dist;
dx=nanmean(diff(dist));
range=layer.Transceivers(idx_freq).get_transceiver_range();
dr=nanmean(diff(range));
w_units=get(region_tab_comp.cell_w_unit,'string');
w_unit_idx=get(region_tab_comp.cell_w_unit,'value');
w_unit=w_units{w_unit_idx};

h_units=get(region_tab_comp.cell_h_unit,'string');
h_unit_idx=get(region_tab_comp.cell_h_unit,'value');
h_unit=h_units{h_unit_idx};

switch get(src,'tag')
    case 'w'
        if region_tab_comp.cell_w_unit_curr==w_unit_idx
            return;
        end
        val=str2double(get(region_tab_comp.cell_w,'string'));
        switch w_unit
            case 'pings'
                val=val/dx;set(region_tab_comp.cell_w,'string',num2str(val,'%.0f'));
            case 'meters'
                val=val*dx;set(region_tab_comp.cell_w,'string',num2str(val,'%.2f'));
                
        end
        region_tab_comp.cell_w_unit_curr=w_unit_idx;
        
    case 'h'
        if region_tab_comp.cell_h_unit_curr==h_unit_idx
            return;
        end
        val=str2double(get(region_tab_comp.cell_h,'string'));
        switch h_unit
            case 'samples'
                val=val/dr;set(region_tab_comp.cell_h,'string',num2str(val,'%.0f'));
            case 'meters'
                val=val*dr;set(region_tab_comp.cell_h,'string',num2str(val,'%.2f'));
        end
        region_tab_comp.cell_h_unit_curr=h_unit_idx;
        
end
setappdata(main_figure,'Region_tab',region_tab_comp);
end
