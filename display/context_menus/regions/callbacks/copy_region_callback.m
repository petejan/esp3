function copy_region_callback(~,~,ID,main_figure,idx_freq_end)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
if~iscell(ID)
    ID={ID};
end

if isempty(ID)
    ID=trans_obj.get_trans_reg_uid();
end

for i=1:numel(ID)
    reg_curr=trans_obj.get_region_from_Unique_ID(ID{i});
    layer.copy_region_across(idx_freq,reg_curr,idx_freq_end);
end

display_regions(main_figure,'all');
end