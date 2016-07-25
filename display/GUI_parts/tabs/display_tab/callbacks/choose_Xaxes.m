function  choose_Xaxes(obj,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
%display_tab_comp=getappdata(main_figure,'Display_tab');
layer=getappdata(main_figure,'Layer');

if ~isempty(layer.Transceivers)
    dp=length(layer.Transceivers(1).Data.get_numbers())/15;
    if ~isempty(layer.GPSData.Time)
        dt=(layer.GPSData.Time(end)-layer.GPSData.Time(1))*24*60*60/15;
        dx=(layer.GPSData.Dist(end)-layer.GPSData.Dist(1))/15;
    else
        dt=(layer.Transceivers(1).Data.Time(end)-layer.Transceivers(1).Data.Time(1))*24*60*60/15;
        dx=1;
    end
else
    return;
end

idx=get(obj,'value');
str=get(obj,'String');
curr_disp.Xaxes=str{idx};

switch curr_disp.Xaxes
    case 'Distance'
        curr_disp.Grid_x=dx;
    case 'Time'
        curr_disp.Grid_x=dt;
    otherwise 
        curr_disp.Grid_x=dp;
end


setappdata(main_figure,'Curr_disp',curr_disp);
update_axis_panel(main_figure,0);
change_grid_callback([],[],main_figure);
end