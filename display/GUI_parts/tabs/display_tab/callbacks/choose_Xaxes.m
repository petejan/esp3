function  choose_Xaxes(obj,~,main_figure)

layer=getappdata(main_figure,'Layer');

curr_disp=getappdata(main_figure,'Curr_disp');
idx=get(obj,'value');
str=get(obj,'String');
curr_disp.Xaxes=str{idx};

if ~isempty(layer.Transceivers)
    init_grid_val(main_figure);
else
    return;
end

setappdata(main_figure,'Curr_disp',curr_disp);

update_grid(main_figure);

end