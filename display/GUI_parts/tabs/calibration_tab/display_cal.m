function display_cal(~,~,main_figure)


layer=getappdata(main_figure,'Layer');

[cal_path,~,~]=fileparts(layer.Filename{1});


[~,idx_sort]=sort(layer.Frequencies);
    figure(); 
    hold on;
    ax_1=subplot(3,1,1);
    xlabel('kHz')
    ylabel('TS(dB)')

    ax_2=subplot(3,1,2);
    xlabel('Frequency (kHz)')
    ylabel('BeamWidth(deg)')
    
    ax_3=subplot(3,1,3);
    xlabel('Frequency (kHz)')
    ylabel('EBA(dB)')

for uui=idx_sort
    file_cal=fullfile(cal_path,['Curve_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
    file_cal_eba=fullfile(cal_path,['Curve_EBA_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
    
    Freq=(layer.Transceivers(uui).Config.Frequency);
    eq_beam_angle=layer.Transceivers(uui).Config.EquivalentBeamAngle;
    
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
    
    
    if ~isempty(cal)
        idx_null=(cal.th_ts)<nanmax(cal.th_ts)-5;
        cal.Gf(idx_null)=nan;
        cal.cal_ts(idx_null)=nan;
    else
        idx_null=[];
    end
    
    
    if ~isempty(cal_eba)
        cal_eba.BeamWidthAlongship_f_fit(idx_null)=nan;
        cal_eba.BeamWidthAthwartship_f_fit(idx_null)=nan;
        eba=10*log10(2.2578*sind(cal_eba.BeamWidthAlongship_f_fit/4+cal_eba.BeamWidthAthwartship_f_fit/4).^2);
    end

   
    if ~isempty(cal)   
        axes(ax_1);
        hold on;
        plot(cal.freq_vec/1e3,cal.cal_ts,'r','linewidth',2);
        hold on;
        plot(cal.freq_vec/1e3,cal.th_ts,'k','linewidth',2);
        grid on;
       ylim([-60 0.9*nanmax(cal.th_ts)])
       legend('Measured','Theoritical');
      
    end

    if ~isempty(cal_eba)
        
        eq_beam_angle_f=eq_beam_angle-20*log10(cal_eba.freq_vec/Freq); 
        
        eba=10*log10(2.2578*sind(cal_eba.BeamWidthAlongship_f_fit/4+cal_eba.BeamWidthAthwartship_f_fit/4).^2);
        BeamWidthAlongship_f_th=2*acosd(1-(cal_eba.freq_vec/Freq).^-2*(1-cosd(layer.Transceivers(uui).Config.BeamWidthAlongship/2)));
        BeamWidthAthwartship_f_th=2*acosd(1-(cal_eba.freq_vec/Freq).^-2*(1-cosd(layer.Transceivers(uui).Config.BeamWidthAthwartship/2)));

        
        axes(ax_2);
        hold on;
        plot(cal_eba.freq_vec/1e3,cal_eba.BeamWidthAlongship_f_fit,'-g','linewidth',2);
        plot(cal_eba.freq_vec/1e3,BeamWidthAlongship_f_th,'-k','linewidth',2);
        plot(cal_eba.freq_vec/1e3,cal_eba.BeamWidthAthwartship_f_fit,'-r','linewidth',2);
        plot(cal_eba.freq_vec/1e3,BeamWidthAthwartship_f_th,'-b','linewidth',2);
        ylim([0.9*nanmin(cal_eba.BeamWidthAlongship_f_th+cal_eba.BeamWidthAthwartship_f_th)/2 1.1*nanmax(cal_eba.BeamWidthAlongship_f_th+cal_eba.BeamWidthAthwartship_f_th)/2])
        legend('Measured Alongship Beamwidth','Theoritical Alongship Beamwidth','Measured Athwardship Beamwidth','Theoritical Athwardship Beamwidth');
        grid on;
        
        axes(ax_3);
        hold on;
        plot(cal_eba.freq_vec/1e3,eba,'-k','linewidth',2);
        plot(cal_eba.freq_vec/1e3,eq_beam_angle_f,'-b','linewidth',2);
        ylim([1.1*nanmin(eq_beam_angle_f) 0.9*nanmax(eq_beam_angle_f)]);
        grid on;
        legend('Measured EBA','Theoritical EBA');
       
    end

end
    linkaxes([ax_1 ax_2 ax_3],'x');
end