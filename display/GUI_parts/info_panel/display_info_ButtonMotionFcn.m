function display_info_ButtonMotionFcn(~,~,main_figure,force_update)


layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

axes_panel_comp=getappdata(main_figure,'Axes_panel');
info_panel_comp=getappdata(main_figure,'Info_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);
Range=trans.get_transceiver_range();
Bottom=trans.Bottom;
Time=trans.Data.Time;
Number=trans.Data.get_numbers();
Samples=trans.Data.get_samples();

Lat=trans.GPSDataPing.Lat;
Long=trans.GPSDataPing.Long;

try
    ax_main=axes_panel_comp.main_axes;
    
    
    x_lim=double(get(ax_main,'xlim'));
    y_lim=double(get(ax_main,'ylim'));
    
    cdata=double(get(axes_panel_comp.main_echo,'CData'));
    [nb_samples_red,nb_pings_red]=size(cdata);
    xdata=double(get(axes_panel_comp.main_echo,'XData'));
    ydata=double(get(axes_panel_comp.main_echo,'YData'));
    
    nb_pings=length(Time);
    nb_samples=length(Range);
    
    if nb_pings_red<nb_pings
        xdata_red=linspace(x_lim(1),x_lim(2),nb_pings_red);
    else
        xdata_red=xdata;
    end
    
    if nb_samples_red<nb_samples
        ydata_red=linspace(y_lim(1),y_lim(2),nb_samples_red);
    else
        ydata_red=ydata;
    end
    
    [idx_r_ori,idx_ping_ori]=get_ori(layer,curr_disp,axes_panel_comp.main_echo);
    
    
    
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
        idx_ping=idx_ping+idx_ping_ori-1;
        [~,idx_r]=nanmin(abs(ydata-y));
        idx_r=idx_r+idx_r_ori-1;
        if nb_pings_red<nb_pings
            [~,idx_ping_red]=nanmin(abs(xdata_red-x));
        else
            idx_ping_red=idx_ping;
        end
        
        if nb_samples_red<nb_samples
            [~,idx_r_red]=nanmin(abs(ydata_red-y));
        else
            idx_r_red=idx_r;
        end
        
        
        if idx_ping<=length(Bottom.Sample_idx)
            if ~isnan(Bottom.Sample_idx(idx_ping))
                bot_val=Range(Bottom.Sample_idx(idx_ping));
            else
                bot_val=nan;
            end
        else
            bot_val=nan;
        end
        
        vert_val=cdata(:,idx_ping_red);
        vert_val(vert_val<=-999)=nan;
        
        bot_x_val=[nanmin(vert_val(~(vert_val==-Inf))) nanmax(vert_val)];
        
        horz_val=cdata(idx_r_red,:);
        horz_val(horz_val<=-999)=nan;
        
        t_n=Time(idx_ping);
        
        i_str='';
        
        if length(layer.SurveyData)>=1
            for is=1:length(layer.SurveyData)
                surv_temp=layer.get_survey_data('Idx',is);
                if ~isempty(surv_temp)
                    if t_n>=surv_temp.StartTime&&t_n<=surv_temp.EndTime
                        i_str=surv_temp.print_survey_data();
                    end
                end
            end
        end
        
        
        xy_string=sprintf('Range: %.2f m Sample: %.0f \n Ping #:%.0f of  %.0f',Range(idx_r),Samples(idx_r),Number(idx_ping),Number(end));
        if ~isempty(Lat)
            pos_string=sprintf('Lat: %.6f \n Long:%.6f',Lat(idx_ping),Long(idx_ping));
        else
            pos_string=sprintf('No Navigation Data');
        end
        time_str=datestr(Time(idx_ping));
        
        switch lower(deblank(curr_disp.Fieldname))
            case{'alongangle','acrossangle'}
                val_str=sprintf('Angle: %.2f deg.',cdata(idx_r_red,idx_ping_red));
            case{'alongphi','acrossphi'}
                val_str=sprintf('Phase: %.2f deg.(phase)',cdata(idx_r_red,idx_ping_red));
            otherwise
                val_str=sprintf('%s: %.2f dB',curr_disp.Type,cdata(idx_r_red,idx_ping_red));
        end
        
        iFile=layer.Transceivers(idx_freq).Data.FileId(idx_ping);
        [~,file_curr,~]=fileparts(layer.Filename{iFile});
        
        time_params=layer.Transceivers(idx_freq).Params.Time;
        [~,idx_params]=min(abs(time_params-Time(idx_ping)));
        
        summary_str=sprintf('%s. Mode: %s Freq: %.0fkHz Power: %.0fW Pulse: %.3fms',file_curr,layer.Transceivers(idx_freq).Mode,curr_disp.Freq/1000,...
            layer.Transceivers(idx_freq).Params.TransmitPower(idx_params),...
            layer.Transceivers(idx_freq).Params.PulseLength(idx_params)*1e3);
        
        
        set(info_panel_comp.i_str,'String',i_str);
        set(info_panel_comp.summary,'string',summary_str);
        set(info_panel_comp.xy_disp,'string',xy_string);
        set(info_panel_comp.pos_disp,'string',pos_string);
        set(info_panel_comp.time_disp,'string',time_str);
        set(info_panel_comp.value,'string',val_str);
        
        axh=axes_panel_comp.haxes;
        axh_plot=axes_panel_comp.h_axes_plot;
        axh_text=axes_panel_comp.h_axes_text;
        
        axv=axes_panel_comp.vaxes;
        axv_plot=axes_panel_comp.v_axes_plot;
        axv_text=axes_panel_comp.v_axes_text;
        
        delete(findobj(axh,'Tag','curr_val'));
        delete(findobj(axv,'Tag','curr_val'));
        
        
        set(axv_plot,'XData',vert_val,'YData',ydata_red);
        
        plot(axv,bot_x_val,[ydata_red(idx_r_red) ydata_red(idx_r_red)],'--b','Tag','curr_val');
        plot(axv,bot_x_val,[bot_val bot_val],'k','Tag','curr_val');
        
        
        axv_text.Position=[nanmean(bot_x_val) bot_val 0];
        axv_text.String=sprintf('%.2fm',trans.get_bottom_range(idx_ping));
        
        set(axv,'ylim',y_lim)
        set(allchild(axv),'visible',get(axv,'visible'))
        y_val=[nanmin(horz_val(~(horz_val==-Inf))) nanmax(horz_val)];
        
        set(axh_plot,'XData',xdata_red,'YData',horz_val);
        
        plot(axh,[xdata_red(idx_ping_red) xdata_red(idx_ping_red)],y_val,'--b','Tag','curr_val');
        set(axh,'xlim',x_lim)
        set(allchild(axh), 'visible',get(axh,'visible'))
        
        hfigs=getappdata(main_figure,'ExternalFigures');
        hfigs(~isvalid(hfigs))=[];
        idx_fig=find(strcmp({hfigs(:).Tag},'nav'));
        for iu=idx_fig
            if isvalid(hfigs(iu))
                hAllAxes = findobj(hfigs(iu),'type','axes');
                if isappdata(hfigs(iu),'Map_info')
                    Map_info=getappdata(hfigs(iu),'Map_info');
                    m_proj(Map_info.Proj,'long',Map_info.LongLim,'lat',Map_info.LatLim);
                end
                if ~isempty(Long)
                    for iui=1:length(hAllAxes)
                        delete(findobj(hAllAxes(iui),'tag','boat_pos'));
                        m_plot(hAllAxes(iui),Long(idx_ping),Lat(idx_ping),'marker','s','markersize',10,'markeredgecolor','r','markerfacecolor','k','tag','boat_pos')
                    end
                end
            end
        end
        
        idx_fig=find(strcmp({hfigs(:).Tag},'attitude'));
        t1=(t_n-Time(1))*24*60*60;
        for iu=idx_fig
            if isvalid(hfigs(iu))
                hAllAxes = findobj(hfigs(iu),'type','axes');
                    for iui=1:length(hAllAxes)
                        delete(findobj(hAllAxes(iui),'tag','time_bar'));
                        plot(hAllAxes(iui),[t1 t1],hAllAxes(iui).YLim,'r','tag','time_bar')
                    end
            end

        end
        
        
    end
    
catch err
    disp(err.message);
    disp('Could not update info panel');
end
end