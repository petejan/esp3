function  choose_freq(src,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
curr_disp.Freq=layer.Frequencies(get(src,'value'));
setappdata(main_figure,'Curr_disp',curr_disp);
set_caxis([],[],main_figure);
end