function display_info_ButtonMotionFcn(~,~,main_figure,force_update)

layer=getappdata(main_figure,'Layer');
if isempty(layer)||~isvalid(layer)
    return;
end

if ~isvalid(layer)
    return;
end

echo_tab_panel=getappdata(main_figure,'echo_tab_panel');

if ~strcmpi(echo_tab_panel.SelectedTab.Tag,'axes_panel')
   return 
end

axes_panel_comp=getappdata(main_figure,'Axes_panel');
info_panel_comp=getappdata(main_figure,'Info_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

[trans_obj,~]=layer.get_trans(curr_disp);
trans=trans_obj;
Range=trans.get_transceiver_range();
Bottom=trans.Bottom;
Time=trans.Time;
Number=trans.get_transceiver_pings();
Samples=trans.get_transceiver_samples();


Depth_corr=trans.get_transducer_depth();

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
    
    
    xdata_red=linspace(x_lim(1),x_lim(2),nb_pings_red);
    ydata_red=linspace(y_lim(1),y_lim(2),nb_samples_red);
    
    
    %[idx_r_ori,idx_ping_ori]=get_ori(layer,curr_disp,axes_panel_comp.main_echo);
    [idx_rs,idx_pings]=get_idx_r_n_pings(layer,curr_disp,axes_panel_comp.main_echo);
    idx_r_ori=idx_rs(1);
    idx_ping_ori=idx_pings(1);
    
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
                bot_val=Bottom.Sample_idx(idx_ping);
            else
                bot_val=nan;
            end
        else
            bot_val=nan;
        end
        switch curr_disp.CursorMode
            case {'Edit Bottom' 'Bad Transmits'}
                switch curr_disp.Fieldname
                    case {'sv','sp','sp_comp','spdenoised','svdenoised','spunmatched','powerunmatched','powerdenoised'}
                        sub_bot=Bottom.Sample_idx(idx_pings)-idx_r_ori;
                        sub_tag=Bottom.Tag(idx_pings);
                        sub_bot(sub_tag==0)=inf;
                        bot_sample_red=downsample(round(sub_bot*nb_samples_red/length(idx_rs)),round(length(idx_pings)/nb_pings_red));
                                               
                        idx_keep=bsxfun(@(x,y) x<=y&x>=y-3  ,(1:nb_samples_red)',bot_sample_red);
                        idx_keep(:,bot_sample_red>=nb_samples)=0;
                        cdata_bot=cdata;
                        cdata_bot(~idx_keep)=nan;
                        horz_val=nanmax(cdata_bot);

                        idx_low=~((horz_val>=prctile(cdata_bot(idx_keep),90))&(horz_val>=(curr_disp.Cax(2)-6)));
                    otherwise
                        horz_val=cdata(idx_r_red,:);
                        horz_val(horz_val<=-999)=nan;
                        idx_low=ones(size(horz_val));
                        %idx_high=zeros(size(horz_val));
                end
            otherwise
                horz_val=cdata(idx_r_red,:);
                horz_val(horz_val<=-999)=nan;
                idx_low=ones(size(horz_val));
                %idx_high=zeros(size(horz_val));
                
        end
        
        
        vert_val=cdata(:,idx_ping_red);
        vert_val(vert_val<=-999)=nan;
        
        bot_x_val=[nanmin(vert_val(~(vert_val==-Inf))) nanmax(vert_val)];
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
        
        if Depth_corr(idx_ping)~=0
            xy_string=sprintf('Range: %.2fm Range Corr: %.2fm\n  Sample: %.0f Ping #:%.0f of  %.0f',Range(idx_r),Range(idx_r)+Depth_corr(idx_ping),Samples(idx_r),Number(idx_ping),Number(end));
        else
            xy_string=sprintf('Range: %.2fm\n  Sample: %.0f Ping #:%.0f of  %.0f',Range(idx_r),Samples(idx_r),Number(idx_ping),Number(end));
        end
        
        if ~isempty(Lat)&&nansum(Lat+Long)>0
            pos_string=print_pos(Lat(idx_ping),Long(idx_ping));
            pos_weigtht='normal';
            pos_col='k';
        else
            pos_string=sprintf('No Navigation Data');
            pos_weigtht='Bold';
            pos_col='r';
        end
        time_str=datestr(Time(idx_ping));
        
        switch lower(deblank(curr_disp.Fieldname))
            case{'alongangle','acrossangle'}
                val_str=sprintf('Angle: %.2f deg.',cdata(idx_r_red,idx_ping_red));
            case{'alongphi','acrossphi'}
                val_str=sprintf('Phase: %.2f deg.(phase)',cdata(idx_r_red,idx_ping_red));
            case {'fishdensity'}
                val_str=sprintf('%s: %.2g fish/m^3',curr_disp.Type,cdata(idx_r_red,idx_ping_red));
            otherwise
                val_str=sprintf('%s: %.2f dB',curr_disp.Type,cdata(idx_r_red,idx_ping_red));
        end
        
        iFile=trans_obj.Data.FileId(idx_ping);
        [~,file_curr,~]=fileparts(layer.Filename{iFile});
        
        time_params=trans_obj.Params.Time;
        [~,idx_params]=min(abs(time_params-Time(idx_ping)));

        summary_str=sprintf('%s. Mode: %s Freq: %.0fkHz Power: %.0fW Pulse: %.3fms',file_curr,trans_obj.Mode,curr_disp.Freq/1000,...
            trans_obj.Params.TransmitPower(idx_params),...
            trans_obj.Params.PulseLength(idx_params)*1e3);
        
        
        set(info_panel_comp.i_str,'String',i_str);
        set(info_panel_comp.summary,'string',summary_str);
        set(info_panel_comp.xy_disp,'string',xy_string);
        set(info_panel_comp.pos_disp,'string',pos_string,'ForegroundColor',pos_col,'Fontweight',pos_weigtht);
        set(info_panel_comp.time_disp,'string',time_str);
        set(info_panel_comp.value,'string',val_str);
        
        axh=axes_panel_comp.haxes;
        axh_plot_high=axes_panel_comp.h_axes_plot_high;
        axh_plot_low=axes_panel_comp.h_axes_plot_low;

        axv=axes_panel_comp.vaxes;
        axv_plot=axes_panel_comp.v_axes_plot;
        axv_text=axes_panel_comp.v_axes_text;
        
        delete(findobj(axh,'Tag','curr_val'));
        delete(findobj(axv,'Tag','curr_val'));
            
        set(axv_plot,'XData',vert_val,'YData',ydata_red);
        
        if bot_x_val(2)>bot_x_val(1)
            set(axv,'xlim',bot_x_val)
        end

        
        plot(axv,bot_x_val,[ydata_red(idx_r_red) ydata_red(idx_r_red)],'--b','Tag','curr_val');
        plot(axv,bot_x_val,([bot_val bot_val]),'k','Tag','curr_val');
        
        axv_text.Position=[nanmean(bot_x_val) bot_val 0];
        axv_text.String=sprintf('%.2fm',trans.get_bottom_range(idx_ping));
        
        
        set(allchild(axv),'visible',get(axv,'visible'))
        y_val=[nanmin(horz_val(~isinf(horz_val))) nanmax(horz_val(~isinf(horz_val)))*10/15^(-1*sign( nanmax(horz_val(~isinf(horz_val)))))];
  
        horz_val_high=horz_val;
        horz_val_high(idx_low>0)=nan;
        
        set(axh_plot_low,'XData',xdata_red,'YData',horz_val);
        set(axh_plot_high,'XData',xdata_red,'YData',horz_val_high);
    
        if x_lim(2)>x_lim(1)
            set(axh,'xlim',x_lim);
            
        end

        
        plot(axh,[xdata_red(idx_ping_red) xdata_red(idx_ping_red)],y_val,'--b','Tag','curr_val');
        
        set(allchild(axh), 'visible',get(axh,'visible'))
        
        try
            map_tab_comp=getappdata(main_figure,'Map_tab');
            if ~isempty(map_tab_comp.Proj)                
                delete(map_tab_comp.boat_pos);
                map_tab_comp.boat_pos=m_plot(map_tab_comp.ax,Long(idx_ping),Lat(idx_ping),'marker','s','markersize',10,'markeredgecolor','r','markerfacecolor','k');
                setappdata(main_figure,'Map_tab',map_tab_comp);
            end
        end
        
        hfigs=getappdata(main_figure,'ExternalFigures');
        if ~isempty(hfigs)
            hfigs(~isvalid(hfigs))=[];
        end
        
        if ~isempty(hfigs)
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
            
            idx_fig=find(strcmp({hfigs(:).Tag},sprintf('attitude%s',layer.Unique_ID)));
            t1=t_n;
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
        
%         switch lower(deblank(curr_disp.Fieldname))
%             case 'sp_comp'
%                 single_target_tab_comp=getappdata(main_figure,'Single_target_tab');
%       
%         end
        
    end
    
catch err
    if ~isdeployed
        disp(err.message);
        disp('Could not update info panel');
    end
end
end