function copy_across_algo(~,~,main_figure,name)
update_algos(main_figure);
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
idx_algo=find_algo_idx(trans_obj,name);
copy_algo_across(layer,trans_obj.Algo(idx_algo));
setappdata(main_figure,'Layer',layer);
end