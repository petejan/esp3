function  choose_type(obj,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

idx_freq=find(layer.Frequencies==curr_disp.Freq,1);

Type=layer.Transceivers(idx_freq).Data.Type;

curr_disp.Type=Type{get(obj,'value')};

setappdata(main_figure,'Curr_disp',curr_disp);
update_display(main_figure,0);
end