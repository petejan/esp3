function  choose_Xaxes(obj,~,main_figure)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');

idx=get(obj,'value');
str=get(obj,'String');

curr_disp.Xaxes_current=str{idx};
update_grid(main_figure);
update_display_tab(main_figure);

end