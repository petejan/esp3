function plot_ping_spectrum_callback(~,~,main_figure)

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


xdata=trans.Data.get_numbers();

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
        
        range=layer.Transceivers(uui).Data.get_range();
        dp=2;
        [Sp_f,Compensation_f,f_vec,r_disp]=processTS_f_v2(layer.Transceivers(uui),layer.EnvData,idx_ping,range,dp,cal);
        
        TS_f=Sp_f+Compensation_f;
        c=(layer.EnvData.SoundSpeed);
        
        pulse_length=(layer.Transceivers(uui).Params.PulseLength(1));
        
        dr=pulse_length*c/(4*dp);
        
        new_echo_figure(main_figure,'Tag','calcurves');
        echo=imagesc(f_vec/1e3,r_disp,TS_f);
        set(echo,'AlphaData',TS_f>-80);
        xlabel('Frequency (kHz)');
        ylabel('Range(m)');
        caxis([-80 -30]); colormap('jet');
        title(sprintf('Ping %i, Frequency resolution %.1f kHz',idx_ping,(c/(2*dr)/1e3)));
   
        
        
        clear Sp_f Compensation_f  f_vec
    else
        fprintf('%s not in  FM mode\n',layer.Transceivers(uui).Config.ChannelID);
        %         f_vec_save=layer.Frequencies;
        %
        %         Sp=layer.Transceivers(uui).Data.get_datamat('AlongAngle');
        %         AlongAngle=layer.Transceivers(uui).Data.get_datamat('AlongAngle');
        %         AcrossAngle=layer.Transceivers(uui).Data.get_datamat('AcrossAngle');
        %
        %         BeamWidthAlongship=layer.Transceivers(uui).Config.BeamWidthAlongship;
        %         BeamWidthAthwartship=layer.Transceivers(uui).Config.BeamWidthAthwartship;
        %
        %         comp=simradBeamCompensation(BeamWidthAlongship,BeamWidthAthwartship , AcrossAngle((idx_pings-1)*length(range)+idx_peak), AlongAngle((idx_pings-1)*length(range)+idx_peak));
        %         TS_f(uui,:)=Sp_max+comp;
    end
end