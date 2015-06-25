function display_info(~,~,main_figure,Transceiver)


axes_panel_comp=getappdata(main_figure,'Axes_panel');
info_panel_comp=getappdata(main_figure,'Info_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

Range=Transceiver.Data.Range;
Time=Transceiver.Data.Time;
Number=Transceiver.Data.Number;
Lat=Transceiver.GPSDataPing.Lat;
Long=Transceiver.GPSDataPing.Long;
%Dist=Transceiver.GPSDataPing.Dist;

ah=axes_panel_comp.main_axes;


% xdata=get(axes_panel_comp.main_echo,'XData');
% ydata=get(axes_panel_comp.main_echo,'YData');

x_lim=double(get(ah,'xlim'));
y_lim=double(get(ah,'ylim'));
xdata=double(get(axes_panel_comp.main_echo,'XData'));
ydata=double(get(axes_panel_comp.main_echo,'YData'));
cdata=double(get(axes_panel_comp.main_echo,'CData'));

cp = ah.CurrentPoint;
x=cp(1,1);
y=cp(1,2);

if x>=x_lim(1)&&x<=x_lim(2)&&y>=y_lim(1)&&y<=y_lim(2)
    [~,idx_ping]=nanmin(abs(xdata-x));
    [~,idx_r]=nanmin(abs(ydata-y));
    xy_string=sprintf('Range: %.2f m\n Ping #:%.0f ',Range(idx_r),Number(idx_ping));
    if ~isempty(Lat)
        pos_string=sprintf('Lat: %.6f \n Long:%.6f',Lat(idx_ping),Long(idx_ping));
    else
        pos_string=sprintf('No Navigation Data');  
    end
    time_str=datestr(Time(idx_ping));
    switch curr_disp.Type
        case{'AlongAngle','AcrossAngle'}
            val_str=sprintf('Angle: %.2f deg.',cdata(idx_r,idx_ping));
        case{'AlongPhi','AcrossPhi'}
            val_str=sprintf('Phase: %.2f deg.(phase)',cdata(idx_r,idx_ping));
        otherwise
            val_str=sprintf('%s: %.2f dB',curr_disp.Type,cdata(idx_r,idx_ping));
    end

    
    set(info_panel_comp.xy_disp,'string',xy_string);
    set(info_panel_comp.pos_disp,'string',pos_string);
    set(info_panel_comp.time_disp,'string',time_str);
    set(info_panel_comp.value,'string',val_str);
    
end

end