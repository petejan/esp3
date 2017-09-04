function plot_ping_sv_spectrum_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);

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
        
        
         file_cal_eba=fullfile(cal_path,[ 'Curve_EBA_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
        
        
        if exist(file_cal_eba,'file')>0
            cal_eba=load(file_cal_eba);
            disp('EBA Calibration file loaded.');
        else
            cal_eba=[];
        end
        range=layer.Transceivers(uui).get_transceiver_range();

        [~,Np]=layer.Transceivers(uui).get_pulse_length();
        [Sv_f,f_vec,r_disp]=layer.Transceivers(uui).processSv_f_r_2(layer.EnvData,idx_ping,range,Np,cal,cal_eba,[]);


       [cmap,col_ax,col_lab,col_grid,~,~]=init_cmap(curr_disp.Cmap);
       df=nanmean(diff(f_vec))/1e3;
        fig=figure();
        ax=axes();
        echo=imagesc(ax,f_vec/1e3,r_disp,Sv_f);
        set(echo,'AlphaData',Sv_f>-80);
        xlabel('Frequency (kHz)');
        ylabel('Range(m)');
        caxis(curr_disp.getCaxField('sv')); colormap(cmap);
        title(sprintf('Sv(f) for %.0fkHz, Ping %i, Frequency resolution %.1f kHz',layer.Frequencies(uui)/1e3,idx_ping,df));
         
        colorbar(ax);
        
        set(ax,'YColor',col_lab);
        set(ax,'XColor',col_lab);
        set(ax,'Color',col_ax,'GridColor',col_grid);

        clear Sp_f Compensation_f  f_vec
        
        new_echo_figure(main_figure,'Tag',sprintf('ts_ping %.0f',df),'fig_handle',fig);
    else
        fprintf('%s not in  FM mode\n',layer.Transceivers(uui).Config.ChannelID);

    end
end