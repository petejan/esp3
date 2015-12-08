function  choose_field(obj,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

idx_freq=find(layer.Frequencies==curr_disp.Freq,1);
field=layer.Transceivers(idx_freq).Data.Fieldname;
curr_disp.setField(field{get(obj,'value')});
setappdata(main_figure,'Curr_disp',curr_disp);
set_caxis([],[],main_figure);
end