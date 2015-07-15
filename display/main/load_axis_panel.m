function load_axis_panel(main_figure,new)

layer=getappdata(main_figure,'Layer');
display_tab_comp=getappdata(main_figure,'Display_tab');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

main_axes=axes_panel_comp.main_axes;

try
    x=double(get(main_axes,'xlim'));
    y=double(get(main_axes,'ylim'));
    
    if new==0
        if isfield(axes_panel_comp,'main_echo')
            xdata_old=double(get(axes_panel_comp.main_echo,'XData'));
            [~,idx_xlim_min]= nanmin(abs(xdata_old-x(1)));
            [~,idx_xlim_max]= nanmin(abs(xdata_old-x(2)));
        else
            idx_xlim_min=1;
            idx_xlim_max=2;
        end
    end
end
idx_freq=find_freq_idx(layer,curr_disp.Freq);

set(display_tab_comp.tog_freq,'String',num2str(layer.Frequencies'),'Value',idx_freq);


[idx_field,found]=find_field_idx(layer.Transceivers(idx_freq).Data,curr_disp.Fieldname);

if found==0
    [idx_field,~]=find_field_idx(layer.Transceivers(idx_freq).Data,'sv');
    curr_disp.Fieldname='sv';
end

set(display_tab_comp.tog_type,'String',layer.Transceivers(idx_freq).Data.Type,'Value',idx_field);

ydata=layer.Transceivers(idx_freq).Data.Range;

%cla(main_axes,'reset')
delete(main_axes)
set(main_figure,'Colormap',jet);
main_axes=axes('Parent', axes_panel_comp.axes_panel,'FontSize',14,'Units','normalized',...
    'Position',[0 0 1 1],...
    'TickDir','in');


switch curr_disp.Xaxes
    case 'Time'
        xdata=layer.Transceivers(idx_freq).Data.Time;
    case 'Number'
        xdata=layer.Transceivers(idx_freq).Data.Number;
    case 'Distance'
        xdata=layer.Transceivers(idx_freq).GPSDataPing.Dist;
        if isempty(xdata)
            disp('NO GPS Data');
            curr_disp.Xaxes='Number';
            xdata=layer.Transceivers(idx_freq).Data.Number;
        end
    otherwise
        xdata=layer.Transceivers(idx_freq).Data.Number;
end



switch lower(deblank(curr_disp.Fieldname))
    case 'y'
        y_c=layer.Transceivers(idx_freq).Data.get_datamat('y');
        data_mat=10*log10(abs(y_c));
    case {'power','powerdenoised'}
        data_mat_lin=layer.Transceivers(idx_freq).Data.get_datamat(curr_disp.Fieldname);
        data_mat_lin(data_mat_lin<=0)=nan;
        data_mat=10*log10(data_mat_lin);
    otherwise
        data_mat=layer.Transceivers(idx_freq).Data.get_datamat(curr_disp.Fieldname);
end

axes(main_axes);
switch curr_disp.Xaxes
    case {'Time','Distance'}
%         xdata_disp=linspace(xdata(1),xdata(end),round(length(xdata)/4));
%         ydata_disp=linspace(ydata(1),ydata(end),round(length(ydata))/4);
%         data_mat_disp=griddata(xdata,ydata,real(data_mat),xdata_disp,ydata_disp');
%         axes_panel_comp.main_echo=imagesc(xdata_disp,ydata_disp,data_mat_disp);
%         
        axes_panel_comp.main_echo=surface(xdata,ydata,real(data_mat));
        view(2)
        shading(main_axes,'flat');
        axis ij
    case 'Number'
        axes_panel_comp.main_echo=imagesc(xdata,ydata,real(data_mat));
    otherwise
        axes_panel_comp.main_echo=imagesc(xdata,ydata,real(data_mat));
end
hold on;

Range_bottom=layer.Transceivers(idx_freq).Bottom.Range;
axes_panel_comp=display_bottom(xdata,Range_bottom,axes_panel_comp,curr_disp.DispBottom);
axes_panel_comp=display_tracks(xdata,layer.Transceivers(idx_freq).ST,layer.Transceivers(idx_freq).Tracks,axes_panel_comp,curr_disp.DispTracks);



ylabel ('Range(m)');
switch curr_disp.Xaxes
    case 'Time'
        xlabel('Time')
    case 'Number'
        xlabel('Ping Number')
    case 'Distance'
        xlabel('Distance')
    otherwise
        xlabel('Ping Number')
end

if new==0 && idx_xlim_min~=idx_xlim_max
    zoom reset
    set(main_axes,'xlim',[xdata(idx_xlim_min) xdata(idx_xlim_max)]);
    set(main_axes,'ylim',y);
else
     zoom reset
end

%colorbar;
grid on;
idx_type=find_field_idx(layer.Transceivers(idx_freq).Data,curr_disp.Fieldname);
cax=layer.Transceivers(idx_freq).Data.SubData(idx_type).CaxisDisplay;

if ~isempty(cax)
    axes(main_axes);
    caxis(cax);
    %curr_disp.Cax=cax;
    set(display_tab_comp.caxis_up,'String',num2str(cax(2),'%.0f'));
    set(display_tab_comp.caxis_down,'String',num2str(cax(1),'%.0f'));
end
axes_panel_comp.main_axes=main_axes;
setappdata(main_figure,'Axes_panel',axes_panel_comp);

if ~isempty(layer.Transceivers(idx_freq).Regions)
    display_regions(main_figure)
end

if ~isempty(cax)
    set_alpha_map(main_figure);
end

end