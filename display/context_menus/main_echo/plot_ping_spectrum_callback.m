function plot_ping_spectrum_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
trans=trans_obj;

ax_main=axes_panel_comp.main_axes;

x_lim=double(get(ax_main,'xlim'));

cp = ax_main.CurrentPoint;
x=cp(1,1);

x=nanmax(x,x_lim(1));
x=nanmin(x,x_lim(2));


xdata=trans.get_transceiver_pings();

[~,idx_ping]=nanmin(abs(xdata-x));
[~,idx_sort]=sort(layer.Frequencies);

[cal_path,~,~]=fileparts(layer.Filename{1});
for uui=idx_sort
    if strcmp(layer.Transceivers(uui).Mode,'FM')
        
        file_cal=fullfile(cal_path,['Curve_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
        
        if exist(file_cal,'file')>0
            cal=load(file_cal);
            disp('Calibration file loaded.');
        else
            disp('No calibration file');
            cal=[];
        end
        
        range=layer.Transceivers(uui).get_transceiver_range();
        dp=1;
        [Sp_f,Compensation_f,f_vec,r_disp]=processTS_f_v2(layer.Transceivers(uui),layer.EnvData,idx_ping,range,dp,cal,[]);
        
        TS_f=Sp_f+Compensation_f;

       [cmap,col_ax,col_lab,col_grid,~,~]=init_cmap(curr_disp.Cmap);
       df=nanmean(diff(f_vec))/1e3;
        fig=new_echo_figure(main_figure,'Tag',sprintf('ts_ping %.0f',df));
        ax=axes();
        echo=image(ax,f_vec/1e3,r_disp,TS_f,'CDataMapping','scaled');
        set(echo,'AlphaData',TS_f>-80);
        xlabel('Frequency (kHz)');
        ylabel('Range(m)');
        caxis(curr_disp.getCaxField('sp')); colormap(cmap);
        title(sprintf('TS(f) for %.0f kHz, Ping %i, Frequency resolution %.1fkHz',layer.Frequencies(uui)/1e3,idx_ping,df));
         
        colorbar(ax);
        
        set(ax,'YColor',col_lab);
        set(ax,'XColor',col_lab);
        set(ax,'Color',col_ax,'GridColor',col_grid);
        grid(ax,'on');
        clear Sp_f Compensation_f  f_vec
        

    else
        fprintf('%s not in  FM mode\n',layer.Transceivers(uui).Config.ChannelID);
    end
end