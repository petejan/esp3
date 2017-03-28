%% update_reglist_tab.m
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
% * |reg_uniqueID|: TODO: write description and info on variable
% * |new|: TODO: write description and info on variable
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
function update_reglist_tab(main_figure,reg_uniqueID,new)

layer=getappdata(main_figure,'Layer');
reglist_tab_comp=getappdata(main_figure,'Reglist_tab');
if isempty(layer)||isempty(reglist_tab_comp)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

regions=trans_obj.Regions;
if ~isempty(reg_uniqueID)&&new==0
    if reg_uniqueID>=0
        region_mod=regions(trans_obj.list_regions_Unique_ID(reg_uniqueID));
        reg_table_data=update_reg_data_table(region_mod,reglist_tab_comp.table.Data);
        set(reglist_tab_comp.table,'Data',reg_table_data);
    else
        idx_mod=find([reglist_tab_comp.table.Data{:,10}]==abs(reg_uniqueID));
        if ~isempty(idx_mod)
            reglist_tab_comp.table.Data(idx_mod,:)=[];
        end
    end
else
    region_mod=regions;
    reg_table_data=update_reg_data_table(region_mod,[]);
    set(reglist_tab_comp.table,'Data',reg_table_data);
end

end