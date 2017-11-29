function copy_region_callback(~,~,main_figure,idx_freq_end)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);


for i=1:length(curr_disp.Active_reg_ID)
    ID=curr_disp.Active_reg_ID{i};    
    reg_curr=trans_obj.get_region_from_Unique_ID(ID);
    layer.copy_region_across(idx_freq,reg_curr,idx_freq_end);
end

display_regions(main_figure,'all');
end