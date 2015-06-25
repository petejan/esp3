function copy_across(~,~,main_figure,name)
update_algos(main_figure);
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
idx_algo=find_algo_idx(layer.Transceivers(idx_freq),name);
copy_algo_across(layer,layer.Transceivers(idx_freq).Algo(idx_algo));

setappdata(main_figure,'Layer',layer);
end