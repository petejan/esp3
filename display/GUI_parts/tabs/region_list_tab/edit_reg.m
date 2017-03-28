
function edit_reg(src,evt,main_figure)
if isempty(evt.Indices)
    return;
end

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);
regions=trans_obj.Regions;
[idx_reg,found]=trans_obj.find_reg_idx(src.Data{evt.Indices(1),10});

if ~found
    return;
end
active_reg=regions(idx_reg);
id=src.Data{evt.Indices(1),2};

if isnan(id)||id<=0
    id=active_reg.ID;
end
active_reg.ID=id;
active_reg.Tag=src.Data{evt.Indices(1),3};
active_reg.Type=src.Data{evt.Indices(1),4};
active_reg.Reference=src.Data{evt.Indices(1),5};
active_reg.Cell_w=src.Data{evt.Indices(1),6};
active_reg.Cell_w_unit=src.Data{evt.Indices(1),7};
active_reg.Cell_h=src.Data{evt.Indices(1),8};
active_reg.Cell_h_unit=src.Data{evt.Indices(1),9};
layer.Transceivers(idx_freq).add_region(active_reg);

setappdata(main_figure,'Layer',layer);
update_regions_tab(main_figure,[]);
display_regions(main_figure,'both');
order_stacks_fig(main_figure);

end
