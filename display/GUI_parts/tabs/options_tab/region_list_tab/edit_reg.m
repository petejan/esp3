%% edit_reg.m
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
% * |evt|: TODO: write description and info on variable
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
function edit_reg(src,evt,main_figure)

if isempty(evt.Indices)
    return;
end

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
trans_obj=trans_obj;
regions=trans_obj.Regions;
[idx_reg,found]=trans_obj.find_reg_idx(src.Data{evt.Indices(1,1),10});

if ~found
    return;
end
active_reg=regions(idx_reg);
id=src.Data{evt.Indices(1,1),2};

if isnan(id)||id<=0
    id=active_reg.ID;
end

active_reg.ID=id;
active_reg.Tag=src.Data{evt.Indices(1,1),3};
active_reg.Type=src.Data{evt.Indices(1,1),4};
active_reg.Reference=src.Data{evt.Indices(1,1),5};
if ~isnan(src.Data{evt.Indices(1,1),6})
    active_reg.Cell_w=src.Data{evt.Indices(1,1),6};
else
    src.Data{evt.Indices(1,1),6}=active_reg.Cell_w;
end
active_reg.Cell_w_unit=src.Data{evt.Indices(1,1),7};

if ~isnan(src.Data{evt.Indices(1,1),8})
   active_reg.Cell_h=src.Data{evt.Indices(1,1),8};
else
    src.Data{evt.Indices(1,1),8}=active_reg.Cell_h;
end
active_reg.Cell_h=src.Data{evt.Indices(1,1),8};
active_reg.Cell_h_unit=src.Data{evt.Indices(1,1),9};
trans_obj.rm_region_id(active_reg.Unique_ID);
trans_obj.add_region(active_reg);

setappdata(main_figure,'Layer',layer);

display_regions(main_figure,'both');
activate_region_callback(active_reg.Unique_ID,main_figure);

order_stacks_fig(main_figure);

end
