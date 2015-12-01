function TS_calibration_curves_func(main_figure,idx_r,~)


options.Interpreter = 'tex';
% Include the desired Default answer
options.Default = 'No thank you';
options.WindowStyle = 'modal';
% Construct a questdlg with two options
qstring='Are you sure that you want to recompute calibration curves? This might delete previously calculated curves.';
choice = questdlg(qstring, ...
    'Calibration', ...
    'Yes','No thank you',options);
% Handle response
switch choice
    case 'No thank you'
        return;
end


layer=getappdata(main_figure,'Layer');
app_path=getappdata(main_figure,'App_path');
curr_disp=getappdata(main_figure,'Curr_disp');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;


idx_freq=find(layer.Frequencies==curr_disp.Freq);
Transceiver=layer.Transceivers(idx_freq);
range=Transceiver.Data.Range;

xdata=get(axes_panel_comp.main_echo,'XData');
ydata=get(axes_panel_comp.main_echo,'YData');


r_min=nanmin(range(idx_r));
r_max=nanmax(range(idx_r));

f_vec_save=[];



for uui=1:length(layer.Frequencies)
    
    range=double(layer.Transceivers(uui).Data.Range);
    ping_num=layer.Transceivers(uui).Data.Number;
    
    bad_trans=zeros(size(ping_num));
    bad_trans(layer.Transceivers(uui).IdxBad)=1;
    
    idx_r=find(range<=r_max&range>=r_min);
    idx_pings=double(ping_num)-double(ping_num(1))+1;
    if isempty(idx_r)
        [~,idx_r]=nanmin(abs(range-r_max));
    end
    
    
    Sp=layer.Transceivers(uui).Data.get_datamat('Sp');
	AlongAngle=layer.Transceivers(uui).Data.get_datamat('AlongAngle');
    AcrossAngle=layer.Transceivers(uui).Data.get_datamat('AcrossAngle');
	
    Freq=(layer.Transceivers(uui).Config.Frequency); 
    pulselength=(layer.Transceivers(uui).Params.PulseLength(1));
    Np=double(round(pulselength/layer.Transceivers(uui).Params.SampleInterval(1)));
    
    [nb_samples,nb_pings]=size(AcrossAngle);
    
    sphere_ts = spherets(2*pi*Freq/layer.EnvData.SoundSpeed, .0381/2, layer.EnvData.SoundSpeed, 6853, 4171, 1025, 14900);
    
    
    Sp_red=Sp(idx_r,:);
    Sp_red(Sp_red>sphere_ts+5)=nan;
    if ~strcmp(layer.Transceivers(uui).Mode,'FM')
        Sp_red=filter2(ones(Np,1),Sp_red)./filter2(ones(Np,1),ones(size(Sp_red)));
    end
    Sp_red(Sp_red<sphere_ts-12)=nan;
    [~,idx_peak]=nanmax(Sp_red,[],1);
    
    
    idx_peak=idx_peak+idx_r(1)-1;
    r_mean=nanmean(range(idx_peak));
    range_red=range(idx_r);
    range_red_mat=repmat(range_red,1,size(Sp_red,2));
    Sp_red(abs(range_red_mat-r_mean)>10)=nan;
    [~,idx_peak]=nanmax(Sp_red,[],1);
    idx_peak=idx_peak+idx_r(1)-1;
    
    AcrossAngle_sph=AcrossAngle(idx_peak+nb_samples*(0:nb_pings-1));
    AlongAngle_sph=AlongAngle(idx_peak+nb_samples*(0:nb_pings-1));
    Sp_sph=Sp(idx_peak+nb_samples*(0:nb_pings-1));
    range_sph=range(idx_peak);
    
    
    
    compensation = simradBeamCompensation(layer.Transceivers(uui).Config.BeamWidthAlongship, layer.Transceivers(uui).Config.BeamWidthAthwartship, AlongAngle_sph, AcrossAngle_sph);
    
    [phi, ~] = simradAnglesToSpherical(AlongAngle_sph, AcrossAngle_sph);
    
    
    idx_low=(Sp_sph<=-60)|compensation>12|bad_trans|(Sp_sph>-30);
    
    
    AlongAngle_sph(idx_low)=[];
    AcrossAngle_sph(idx_low)=[];
    Sp_sph(idx_low)=[];
    idx_peak(idx_low)=[];
    idx_pings(idx_low)=[];
    phi(idx_low)=[];
    compensation(idx_low)=[];
    range_sph(idx_low)=[];
    
    
    if idx_freq==uui
        axes(ah);
        hold on;
        plot(xdata(idx_pings),ydata(idx_peak),'color','r','linewidth',2);
        drawnow
    end
    
    
    if strcmp(layer.Transceivers(uui).Mode,'FM')
        
        xi=linspace(nanmin(AlongAngle_sph),nanmax(AlongAngle_sph),1000);
        yi=linspace(nanmin(AcrossAngle_sph),nanmax(AcrossAngle_sph),1000);
        
        [XI,YI]=meshgrid(xi,yi);
        ZI = griddata(AlongAngle_sph,AcrossAngle_sph,Sp_sph, XI, YI);
        
        
        figure()
        subplot(1,length(layer.Frequencies),uui)
        contourf(XI, YI, ZI)
        hold on
        plot(AlongAngle_sph,AcrossAngle_sph,'+','MarkerSize',2,'MarkerEdgeColor',[.5 .5 .5])
        axis equal
        grid on;
        colormap(jet)
        shading interp
        xlabel('Port/stbd angle (\circ)')
        ylabel('Fore/aft angle (\circ)')
        title(sprintf('%.0f kHz',Freq/1e3))
        caxis([-55 -36])
        axis equal;
        drawnow;
        
        
        figure()
        subplot(1,length(layer.Frequencies),uui)
        surf(XI, YI, ZI)
        shading interp
        hold on;
        %surf(XI, YI, ZI_comp)
        axis equal
        grid on;
        colormap(jet)
        zlabel('TS (dB re 1m^2)')
        xlabel('Port/stbd angle (\circ)')
        ylabel('Fore/aft angle (\circ)')
        title(sprintf('%.0f kHz',Freq/1e3))
        caxis([-55 -36])
        drawnow;
        
        idx_low=(Sp_sph<=-60)|abs(phi)>0.1|compensation>12;
        idx_peak(idx_low)=[];
        idx_pings(idx_low)=[];
        range_sph(idx_low)=[];
        
        if idx_freq==uui
            axes(ah);
            hold on;
            plot(idx_pings,range(idx_peak),'.r','markersize',5);        
            drawnow;
        end
        
        if isempty(idx_peak)
            break;
        end
        
        for kk=1:length(idx_pings)
            [Sp_f(:,kk),Compensation_f(:,kk),f_vec(:,kk)]=processTS_f(layer.Transceivers(uui),layer.EnvData,idx_pings(kk),range(idx_peak(kk)),[]);
        end
        
        TS_f=Sp_f+Compensation_f;
        
        TS_f_mean=10*log10(nanmean(10.^(TS_f'/10)));
        
        figure()
        hold on;
        %subplot(1,3,uui)
        plot(f_vec/1e3,TS_f,'b','linewidth',0.2);
        hold on;
        plot(f_vec(:,1)/1e3,TS_f_mean,'r','linewidth',2)
        grid on;
        xlabel('kHz')
        ylabel('TS(dB)')
        
        th_ts=nan(1,length(f_vec(:,1)));
        for jj=1:length(f_vec(:,1))
            th_ts(jj) = spherets(2*pi*f_vec(jj,1)/layer.EnvData.SoundSpeed, .0381/2, layer.EnvData.SoundSpeed, 6853, 4171, 1025, 14900);
        end
        
        
        app_path.cal=layer.PathToFile;
        file_cal=[app_path.cal 'Curve_' num2str(layer.Frequencies(uui),'%.0f') '.mat'];
        
        freq_vec=f_vec(:,1);
        cal_ts=TS_f_mean;
        Gf=(cal_ts-th_ts)/2;
        
        save(file_cal,'freq_vec','cal_ts','th_ts','Gf');
        
        f_vec_save=[f_vec_save; freq_vec];
        
        clear Sp_f Compensation_f TS_f f_vec TS_f_mean
    else
        fprintf('%s not in  FM mode\n',layer.Transceivers(uui).Config.ChannelID);
        
        for uui=1:length(layer.Frequencies)
            layer.Transceivers(uui)=process_data(layer.Transceivers(uui),layer.EnvData,idx_peak,idx_pings);
        end
    end
end

if ~isempty(f_vec_save)
    f_vec_2=f_vec_save(1):100:f_vec_save(end);
    ts=nan(1,length(f_vec_2));
    
    for jj=1:length(f_vec_2)
        ts(jj) = spherets(2*pi*f_vec_2(jj)/layer.EnvData.SoundSpeed, .0381/2, layer.EnvData.SoundSpeed, 6853, 4171, 1025, 14900);
    end
    
    figure()
    hold on;
    plot(f_vec_2/1e3,ts,'k','linewidth',2)
end

set(main_figure,'WindowButtonDownFcn','');

setappdata(main_figure,'Layer',layer);
setappdata(main_figure,'App_path',app_path);
end
