function display_cal(~,~,main_figure)


layer=getappdata(main_figure,'Layer');

[cal_path,~,~]=fileparts(layer.Filename{1});


[~,idx_sort]=sort(layer.Frequencies);
    new_echo_figure(main_figure,'Tag','calibration');

    
    ax_1=subplot(3,1,1);
    hold(ax_1,'on');
    xlabel('kHz')
    ylabel('TS(dB)')

    ax_2=subplot(3,1,2);
    hold(ax_2,'on');
    xlabel('Frequency (kHz)')
    ylabel('BeamWidth(deg)')
    
    ax_3=subplot(3,1,3);
    hold(ax_3,'on');
    xlabel('Frequency (kHz)')
    ylabel('EBA(dB)')

for uui=idx_sort
    Freq=(layer.Transceivers(uui).Config.Frequency);
    eq_beam_angle=layer.Transceivers(uui).Config.EquivalentBeamAngle;
    
    if ~isempty(layer.Transceivers(uui).Config.Cal_FM)
        %<FrequencyPar Frequency="222062" Gain="30.09" Impedance="75" Phase="0" BeamWidthAlongship="5.43" BeamWidthAthwartship="5.64" AngleOffsetAlongship="0.04" AngleOffsetAthwartship="0.04" />
        cal_eba_ori.BeamWidthAlongship_f_fit=layer.Transceivers(uui).Config.Cal_FM.BeamWidthAlongship;
        cal_eba_ori.BeamWidthAthwartship_f_fit=layer.Transceivers(uui).Config.Cal_FM.BeamWidthAthwartship;
        cal_eba_ori.freq_vec=layer.Transceivers(uui).Config.Cal_FM.Frequency;
        cal_ori.freq_vec=layer.Transceivers(uui).Config.Cal_FM.Frequency;
        cal_ori.Gf=layer.Transceivers(uui).Config.Cal_FM.Gain;
        
    else
        cal_ori=[];
        cal_eba_ori=[];
    end
    
    file_cal=fullfile(cal_path,['Curve_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
    file_cal_eba=fullfile(cal_path,['Curve_EBA_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
    if exist(file_cal,'file')>0
        cal=load(file_cal);
    else
        cal=[];
    end
    
    if exist(file_cal_eba,'file')>0
        cal_eba=load(file_cal_eba);
    else
        cal_eba=[];
    end
    
    
%     if ~isempty(cal)
%         idx_null=(cal.th_ts)<nanmax(cal.th_ts)-5;
%         cal.Gf(idx_null)=nan;
%         cal.cal_ts(idx_null)=nan;
%     else
        idx_null=[];
%     end
%     
    
    if ~isempty(cal_eba)
        cal_eba.BeamWidthAlongship_f_fit(idx_null)=nan;
        cal_eba.BeamWidthAthwartship_f_fit(idx_null)=nan;
        eba=10*log10(2.2578*sind(cal_eba.BeamWidthAlongship_f_fit/4+cal_eba.BeamWidthAthwartship_f_fit/4).^2);
    end

    if ~isempty(cal)   
       plot(ax_1,cal.freq_vec(:)/1e3,cal.Gf(:),'r','linewidth',2);
       grid(ax_1,'on');
     end
    
    if~isempty(cal_ori)
        plot(ax_1,cal_ori.freq_vec/1e3,cal_ori.Gf,'k','linewidth',2);
    end

    if ~isempty(cal_eba)
        
        eq_beam_angle_f=eq_beam_angle-20*log10(cal_eba.freq_vec/Freq); 
        
        eba=10*log10(2.2578*sind(cal_eba.BeamWidthAlongship_f_fit/4+cal_eba.BeamWidthAthwartship_f_fit/4).^2);
        
        BeamWidthAlongship_f_th=2*acosd(1-(cal_eba.freq_vec/Freq).^-2*(1-cosd(layer.Transceivers(uui).Config.BeamWidthAlongship/2)));
        BeamWidthAthwartship_f_th=2*acosd(1-(cal_eba.freq_vec/Freq).^-2*(1-cosd(layer.Transceivers(uui).Config.BeamWidthAthwartship/2)));


        
        plot(ax_2,cal_eba.freq_vec/1e3,cal_eba.BeamWidthAlongship_f_fit,'-g','linewidth',2);
        plot(ax_2,cal_eba.freq_vec/1e3,BeamWidthAlongship_f_th,'-k','linewidth',2);
        plot(ax_2,cal_eba.freq_vec/1e3,cal_eba.BeamWidthAthwartship_f_fit,'-r','linewidth',2);
        plot(ax_2,cal_eba.freq_vec/1e3,BeamWidthAthwartship_f_th,'-b','linewidth',2);
        ylim(ax_2,[nanmin(cal_eba.BeamWidthAthwartship_f_th)*0.7 nanmax(cal_eba.BeamWidthAlongship_f_th)*1.3]); 
        grid(ax_2,'on');
        legend(ax_2,'Measured Alongship Beamwidth','Theoritical Alongship Beamwidth','Measured Athwardship Beamwidth','Theoritical Athwardship Beamwidth');
       

        
        plot(ax_3,cal_eba.freq_vec/1e3,eba,'-k','linewidth',2);
        plot(ax_3,cal_eba.freq_vec/1e3,eq_beam_angle_f,'-b','linewidth',2);
        ylim(ax_3,[1.1*nanmin(eq_beam_angle_f) 0.9*nanmax(eq_beam_angle_f)]);
        grid(ax_3,'on');
        legend('Measured EBA','Theoritical EBA');
       
    end

end
    linkaxes([ax_1 ax_2 ax_3],'x');
end