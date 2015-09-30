function display_info(~,~,main_figure,force_update)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
info_panel_comp=getappdata(main_figure,'Info_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);

Range=trans.Data.Range;
Time=trans.Data.Time;
Number=trans.Data.Number;
Samples=trans.Data.Samples;
Lat=trans.GPSDataPing.Lat;
Long=trans.GPSDataPing.Long;
%Dist=trans.GPSDataPing.Dist;

ax_main=axes_panel_comp.main_axes;
axh=axes_panel_comp.haxes;
axv=axes_panel_comp.vaxes;


% xdata=get(axes_panel_comp.main_echo,'XData');
% ydata=get(axes_panel_comp.main_echo,'YData');

x_lim=double(get(ax_main,'xlim'));
y_lim=double(get(ax_main,'ylim'));
xdata=double(get(axes_panel_comp.main_echo,'XData'));
ydata=double(get(axes_panel_comp.main_echo,'YData'));
cdata=double(get(axes_panel_comp.main_echo,'CData'));

cp = ax_main.CurrentPoint;
x=cp(1,1);
y=cp(1,2);

if (x>x_lim(2)||x<x_lim(1)|| y>y_lim(2)||y<y_lim(1)||gcf~=main_figure)&&force_update==0
    return;
end
    
x=nanmax(x,x_lim(1));
x=nanmin(x,x_lim(2));

y=nanmax(y,y_lim(1));
y=nanmin(y,y_lim(2));

if ~isempty(cdata)
    [~,idx_ping]=nanmin(abs(xdata-x));
    [~,idx_r]=nanmin(abs(ydata-y));
    xy_string=sprintf('Range: %.2f m Sample: %.0f \n Ping #:%.0f of  %.0f',Range(idx_r),Samples(idx_r),Number(idx_ping),Number(end));
    if ~isempty(Lat)
        pos_string=sprintf('Lat: %.6f \n Long:%.6f',Lat(idx_ping),Long(idx_ping));
    else
        pos_string=sprintf('No Navigation Data');  
    end
    time_str=datestr(Time(idx_ping));
    
    switch lower(deblank(curr_disp.Fieldname))
        case{'alongangle','acrossangle'}
            val_str=sprintf('Angle: %.2f deg.',cdata(idx_r,idx_ping));  
        case{'alongphi','acrossphi'}
            val_str=sprintf('Phase: %.2f deg.(phase)',cdata(idx_r,idx_ping));
        otherwise
            val_str=sprintf('%s: %.2f dB',curr_disp.Type,cdata(idx_r,idx_ping));
    end
   
    set(info_panel_comp.xy_disp,'string',xy_string);
    set(info_panel_comp.pos_disp,'string',pos_string);
    set(info_panel_comp.time_disp,'string',time_str);
    set(info_panel_comp.value,'string',val_str);
    
    delete(findall(axv,'Type','Line'));
    axes(axv);     
    plot(cdata(:,idx_ping),ydata,'k');
    set(axv,'ylim',y_lim)
    set(allchild(axv),'visible',get(axv,'visible'))
    
    delete(findall(axh,'Type','Line'));
    axes(axh);
    plot(xdata,cdata(idx_r,:),'r');
    set(axh,'xlim',x_lim)
    set(allchild(axh), 'visible',get(axh,'visible'))
end

update_xtick_labels([],[],axh,curr_disp.Xaxes);
update_ytick_labels([],[],axv);

end