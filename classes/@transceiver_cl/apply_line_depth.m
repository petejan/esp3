function [ping_new_mat,depth_new_mat,data_new]=apply_line_depth(trans_obj,curr_field)

line_obj=trans_obj.OffsetLine;
if isempty(line_obj)
    ping_new_mat=[];
    depth_new_mat=[];
    data_new=[];
    return;
end

data_new=trans_obj.Data.get_datamat(curr_field);
depth_new_mat=trans_obj.get_transceiver_depth([],[]);
ping_new_mat=repmat(1:size(depth_new_mat,2),size(depth_new_mat,1),1);




