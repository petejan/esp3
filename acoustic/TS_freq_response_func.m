function TS_freq_response_func(main_figure,idx_r,idx_pings)


layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
app_path=getappdata(main_figure,'App_path');
ah=axes_panel_comp.main_axes;
idx_freq=find_freq_idx(layer,curr_disp.Freq);
range=layer.Transceivers(idx_freq).Data.Range;

r_min=nanmin(range(idx_r));
r_max=nanmax(range(idx_r));


xdata=get(axes_panel_comp.main_echo,'XData');
ydata=get(axes_panel_comp.main_echo,'YData');

f_vec_save=[];

TS_f=[];

cal_path=app_path.cal;
if isempty(cal_path)
    cal_path=layer.PathToFile;
end

[~,idx_sort]=sort(layer.Frequencies);
for uui=idx_sort
    range=layer.Transceivers(uui).Data.Range;
    idx_r=find(range<=r_max&range>=r_min);
    
    if isempty(idx_r)
        [~,idx_r]=nanmin(abs(range-r_max));
    end
       

    Sp=layer.Transceivers(uui).Data.get_datamat('Sp');
    Sp_red=Sp(idx_r,idx_pings);
    
    [Sp_max,idx_peak]=nanmax(Sp_red,[],1);
    idx_peak=idx_peak+idx_r(1)-1;
    
    if idx_freq==uui
        axes(ah);
        hold on;
        plot(xdata(idx_pings),ydata(idx_peak),'color','r','linewidth',2);
    end
    
    if strcmp(layer.Transceivers(uui).Mode,'FM')
        
        file_cal=[cal_path 'Curve_' num2str(layer.Frequencies(uui),'%.0f') '.mat'];
        
        if exist(file_cal,'file')>0
            cal=load(file_cal);
            disp('Calibration file loaded.');
        else
            disp('No calibration file');
            cal=[];
        end
        
        
        for kk=1:length(idx_pings)
            [Sp_f(:,kk),Compensation_f(:,kk),f_vec(:,kk)]=processTS_f(layer.Transceivers(uui),layer.EnvData,idx_pings(kk),range(idx_peak(kk)),cal);
        end
        TS_f=[TS_f; Sp_f+Compensation_f];
        
        f_vec_save=[f_vec_save; f_vec(:,1)];
        
                
        
        clear Sp_f Compensation_f  f_vec
    else
        fprintf('%s not in  FM mode\n',layer.Transceivers(uui).Config.ChannelID);
        f_vec_save=layer.Frequencies;

        AlongAngle=layer.Transceivers(uui).Data.get_datamat('AlongAngle');
        AcrossAngle=layer.Transceivers(uui).Data.get_datamat('AcrossAngle');
        
        BeamWidthAlongship=layer.Transceivers(uui).Config.BeamWidthAlongship;
        BeamWidthAthwartship=layer.Transceivers(uui).Config.BeamWidthAthwartship;

        comp=simradBeamCompensation(BeamWidthAlongship,BeamWidthAthwartship , AcrossAngle((idx_pings-1)*length(range)+idx_peak), AlongAngle((idx_pings-1)*length(range)+idx_peak));
        TS_f(uui,:)=Sp_max+comp;
    end
end

if ~isempty(f_vec_save)
    
%     f_vec_2=f_vec_save(1):1000:f_vec_save(end);
%     ts=nan(1,length(f_vec_2));
%     
%     
%     for jj=1:length(f_vec_2)
%         ts(jj) = spherets(2*pi*f_vec_2(jj)/layer.EnvData.SoundSpeed, .0381/2, layer.EnvData.SoundSpeed, 6853, 4171, 1025, 14900);
%     end
%     
    TS_f_mean=10*log10(nanmean(10.^(TS_f'/10)));    
    figure();
    %plot(f_vec_save/1e3,TS_f,'b','linewidth',0.2);
    hold on;
    plot(f_vec_save/1e3,TS_f_mean,'r','linewidth',2)
    grid on;
    xlabel('kHz')
    ylabel('TS(dB)')
    
%     hold on;
%     plot(f_vec_2/1e3,ts,'k','linewidth',2)
end

end
