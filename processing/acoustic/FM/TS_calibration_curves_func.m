function TS_calibration_curves_func(main_figure)


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
curr_disp=getappdata(main_figure,'Curr_disp');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;
idx_freq=find(layer.Frequencies==curr_disp.Freq);


f_vec_save=[];

TS_fig=new_echo_figure(main_figure,'Name','TS','Tag','TS_fig');
BP_fig_1=new_echo_figure(main_figure,'Name','','Tag','BP_fig1');
BP_fig=new_echo_figure(main_figure,'Name','','Tag','BP_fig');

for uui=1:length(layer.Frequencies)
    
   
    
    
    range=double(layer.Transceivers(uui).Data.get_range());
    ping_num=layer.Transceivers(uui).Data.get_numbers();
    
    mask=layer.Transceivers(uui).mask_from_regions();
    
    
    [samples_m,~]=find(mask);
    
    r_min=nanmin(range(samples_m));
    r_max=nanmax(range(samples_m));
    
    if isempty(r_min)||isempty(r_max)
        continue;
    end
    
    bad_trans=zeros(size(ping_num));
    bad_trans(layer.Transceivers(idx_freq).Bottom.Tag==0)=1;
    mask(:,bad_trans==1)=0;
    
    idx_r=find(range<=r_max&range>=r_min);
    
    if isempty(idx_r)
        [~,idx_r]=nanmin(abs(range-r_max));
    end
    
    idx_pings=find(nansum(mask)>0);
    
    
    Sp=layer.Transceivers(uui).Data.get_datamat('Sp');
    Sp(mask==0)=nan;
    AlongAngle=layer.Transceivers(uui).Data.get_datamat('AlongAngle');
    AcrossAngle=layer.Transceivers(uui).Data.get_datamat('AcrossAngle');
    
    Freq=(layer.Transceivers(uui).Config.Frequency);
    pulselength=(layer.Transceivers(uui).Params.PulseLength(1));
    Np=double(round(pulselength/layer.Transceivers(uui).Params.SampleInterval(1)));
    
    [nb_samples,~]=size(AcrossAngle);
    
    sphere_ts = spherets(2*pi*Freq/layer.EnvData.SoundSpeed, .0381/2, layer.EnvData.SoundSpeed, 6853, 4171, 1025, 14900);
    
    
    Sp_red=Sp(idx_r,idx_pings);
    Sp_red(Sp_red>sphere_ts+5)=nan;
    if ~strcmp(layer.Transceivers(uui).Mode,'FM')
        Sp_red=filter(ones(Np,1)/Np,1,Sp_red)./filter2(ones(Np,1),ones(size(Sp_red)));
    end
    Sp_red(Sp_red<sphere_ts-20)=nan;
    [~,idx_peak]=nanmax(Sp_red,[],1);
    
    
    idx_peak=idx_peak+idx_r(1)-1;
    r_mean=nanmean(range(idx_peak));
    range_red=range(idx_r);
    range_red_mat=repmat(range_red,1,size(Sp_red,2));
    Sp_red(abs(range_red_mat-r_mean)>10)=nan;
    [~,idx_peak]=nanmax(Sp_red,[],1);
    idx_peak=idx_peak+idx_r(1)-1;
    
    AcrossAngle_sph=AcrossAngle(idx_peak+nb_samples*(idx_pings-1));
    AlongAngle_sph=AlongAngle(idx_peak+nb_samples*(idx_pings-1));
    Sp_sph=Sp(idx_peak+nb_samples*(idx_pings-1));
    range_sph=range(idx_peak);
    
    t=layer.EnvData.Temperature;
    t_sphere=layer.EnvData.Temperature;
    s_sphere=layer.EnvData.Salinity;
    s=layer.EnvData.Salinity;
    d=nanmean(range(range<nanmean(range_sph)));
    
    density_at_sphere = sw_dens(s_sphere, layer.EnvData.Temperature, nanmean(range_sph));
    c_at_sphere = sw_svel(s_sphere, t_sphere, nanmean(range_sph));
    
    % mean parameters over range from transducer to the sphere
    c = sw_svel(s, t, d);
    alpha = sw_absorption(Freq/1e3, s, t, d,'fandg');

    sphere_ts = spherets(2*pi*Freq/c, .0381/2, c_at_sphere, ...
        6853, 4171, density_at_sphere, 14900);
    
    % print out the parameters
    disp(['sound speed at sphere = ' num2str(c_at_sphere) ' m/s'])
    disp(['density at sphere = ' num2str(density_at_sphere) ' kg/m^3'])
    
    disp(['mean Absorption = ' num2str(alpha) ' dB/km'])
    disp(['mean sound speed = ' num2str(c) ' m/s'])
    disp(['sphere TS = ' num2str(sphere_ts) ' dB'])
    for it=1:length(layer.Transceivers)
        layer.Transceivers(it).apply_soundspeed(layer.EnvData.SoundSpeed,c);  
    end
    layer.apply_soundspeed(c);
    layer.Transceivers(uui).apply_absorption(alpha/1e3);
    
    update_axis_panel(main_figure,0);
    update_calibration_tab(main_figure);
    display_bottom(main_figure);
    display_tracks(main_figure);
    display_file_lines(main_figure);
    display_regions(main_figure,'both');
    display_survdata_lines(main_figure);
    set_alpha_map(main_figure);
    order_axes(main_figure);
    order_stacks_fig(main_figure);


    compensation = simradBeamCompensation(layer.Transceivers(uui).Config.BeamWidthAlongship, layer.Transceivers(uui).Config.BeamWidthAthwartship, AlongAngle_sph, AcrossAngle_sph);
    
    [phi, ~] = simradAnglesToSpherical(AlongAngle_sph, AcrossAngle_sph);
    
    
    idx_low=compensation>18|(Sp_sph>-30)|idx_peak==idx_r(1);
    
    %idx_low=idx_peak==idx_r(1)  ;
    
    AlongAngle_sph(idx_low)=[];
    AcrossAngle_sph(idx_low)=[];
    Sp_sph(idx_low)=[];
    idx_peak(idx_low)=[];
    idx_pings(idx_low)=[];
    phi(idx_low)=[];
    compensation(idx_low)=[];
    range_sph(idx_low)=[];
    
    
    if idx_freq==uui
        switch curr_disp.Xaxes
            case 'Number'
                axes(ah);
                hold on;
                plot(layer.Transceivers(uui).Data.get_numbers(idx_pings),layer.Transceivers(uui).Data.get_range(idx_peak),'+r','linewidth',2);
                drawnow
            otherwise
                
        end
    end
    
    
    if strcmp(layer.Transceivers(uui).Mode,'FM')
        
        xi=linspace(nanmin(AlongAngle_sph),nanmax(AlongAngle_sph),1000);
        yi=linspace(nanmin(AcrossAngle_sph),nanmax(AcrossAngle_sph),1000);
        
        [XI,YI]=meshgrid(xi,yi);
        ZI = griddata(AlongAngle_sph,AcrossAngle_sph,Sp_sph, XI, YI);
        
        
        figure(BP_fig_1)
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
        
        
        figure(BP_fig)
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
            disp('Not enough central echoes');
            continue;
        end
        
        for kk=1:length(idx_pings)
            [Sp_f(:,kk),Compensation_f(:,kk),f_vec(:,kk)]=processTS_f(layer.Transceivers(uui),layer.EnvData,idx_pings(kk),range(idx_peak(kk)),[]);
        end
        
        TS_f=Sp_f+Compensation_f;
        
        TS_f_mean=10*log10(nanmean(10.^(TS_f'/10)));
        
        figure(TS_fig);
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
        
        
        
        [cal_path,~,~]=fileparts(layer.Filename{1});
        file_cal=fullfile(cal_path,['Curve_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
        
        freq_vec=f_vec(:,1);
        cal_ts=TS_f_mean;
        Gf=(cal_ts-th_ts)/2;
        
        save(file_cal,'freq_vec','cal_ts','th_ts','Gf');
        
        f_vec_save=[f_vec_save; freq_vec];
        
        clear Sp_f Compensation_f TS_f f_vec TS_f_mean
    else
        fprintf('%s not in  FM mode\n',layer.Transceivers(uui).Config.ChannelID);
        if uui==1
            close(TS_fig);
            close(BP_fig_1);
            close(BP_fig);
        end
        layer.Transceivers(uui)=process_data(layer.Transceivers(uui),layer.EnvData,idx_peak,idx_pings,sphere_ts);
    end
end

if ~isempty(f_vec_save)
    f_vec_2=f_vec_save(1):100:f_vec_save(end);
    ts=nan(1,length(f_vec_2));
    
    for jj=1:length(f_vec_2)
        ts(jj) = spherets(2*pi*f_vec_2(jj)/layer.EnvData.SoundSpeed, .0381/2, layer.EnvData.SoundSpeed, 6853, 4171, 1025, 14900);
    end
    
    figure(TS_fig)
    hold on;
    plot(f_vec_2/1e3,ts,'k','linewidth',2)
end


setappdata(main_figure,'Layer',layer);
loadEcho(main_figure);

end
