function  choose_field(obj,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
trans_obj=layer.get_trans(curr_disp);
field=trans_obj.Data.Fieldname;

curr_disp.setField(field{get(obj,'value')});
setappdata(main_figure,'Curr_disp',curr_disp);
end