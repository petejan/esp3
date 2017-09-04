function beamwidth_calibration_curves_func(main_figure)


show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');


layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

idx_freq=find_freq_idx(layer,curr_disp.Freq);

ah=axes_panel_comp.main_axes;


calibration_tab_comp=getappdata(main_figure,'Calibration_tab');
sphere_list=get(calibration_tab_comp.sphere,'String');
sph=get_sph_params(sphere_list{get(calibration_tab_comp.sphere,'value')});



for uui=1:length(layer.Frequencies)
    
    
    
    range=layer.Transceivers(uui).get_transceiver_range();
    ping_num=layer.Transceivers(uui).get_transceiver_pings();
    mask=layer.Transceivers(uui).mask_from_regions();
    
    [samples_m,~]=find(mask);
    
    r_min=nanmin(range(samples_m));
    r_max=nanmax(range(samples_m));
    
    if isempty(r_min)||isempty(r_max)
        continue;
    end
    
    bad_trans=zeros(size(ping_num));
    bad_trans(layer.Transceivers(uui).Bottom.Tag==0)=1;
    mask(:,bad_trans==1)=0;
    
    idx_r=find(range<=r_max&range>=r_min);
    
    if isempty(idx_r)
        [~,idx_r]=nanmin(abs(range-r_max));
    end
    
    idx_pings=find(nansum(mask)>0);
    
    
    
    Sp=layer.Transceivers(uui).Data.get_datamat('Sp');
    AlongAngle=layer.Transceivers(uui).Data.get_datamat('AlongAngle');
    AcrossAngle=layer.Transceivers(uui).Data.get_datamat('AcrossAngle');
    
    
    Freq=(layer.Transceivers(uui).Config.Frequency);
    %eq_beam_angle=layer.Transceivers(uui).Config.EquivalentBeamAngle;
    sphere_ts = spherets(2*pi*Freq/layer.EnvData.SoundSpeed,sph.radius, layer.EnvData.SoundSpeed, ...
        sph.lont_c, sph.trans_c, sph.rho_water, sph.rho);
    
    [nb_samples,~]=size(AcrossAngle);
    
    Sp_red=Sp(idx_r,idx_pings);
    [~,idx_peak]=nanmax(Sp_red,[],1);
    idx_peak=idx_peak+idx_r(1)-1;
    
    AcrossAngle_sph=AcrossAngle(idx_peak+nb_samples*(idx_pings-1));
    AlongAngle_sph=AlongAngle(idx_peak+nb_samples*(idx_pings-1));
    Sp_sph=Sp(idx_peak+nb_samples*(idx_pings-1));
    
    
    faBW = layer.Transceivers(uui).Config.BeamWidthAlongship; % [degrees]
    psBW = layer.Transceivers(uui).Config.BeamWidthAthwartship; % [degrees]
    
    est_ts = sphere_ts-simradBeamCompensation(faBW, psBW, AlongAngle_sph, AcrossAngle_sph);
    
    idx_low=idx_peak==idx_r(1)|abs(Sp_sph-est_ts)>3  ;
    
    
    AlongAngle_sph(idx_low)=[];
    AcrossAngle_sph(idx_low)=[];
    Sp_sph(idx_low)=[];
    idx_peak(idx_low)=[];
    idx_pings(idx_low)=[];
    
    if isempty(AlongAngle_sph)
        return;
    end
    
    xi=linspace(nanmin(AlongAngle_sph),nanmax(AlongAngle_sph),1000);
    yi=linspace(nanmin(AcrossAngle_sph),nanmax(AcrossAngle_sph),1000);
    [XI,YI]=meshgrid(xi,yi);
    ZI = griddata(AlongAngle_sph,AcrossAngle_sph,Sp_sph, XI, YI);
    
    new_echo_figure(main_figure,'Name','Beam Pattern','Tag',sprintf('Bp%.0f',uui));
    subplot(1,length(layer.Frequencies),uui)
    contourf(XI, YI, ZI,10)
    hold on
    plot(AlongAngle_sph,AcrossAngle_sph,'+','MarkerSize',2,'MarkerEdgeColor',[.5 .5 .5])
    axis equal
    grid on;
    colormap(jet)
    xlabel('Port/stbd angle (\circ)')
    ylabel('Fore/aft angle (\circ)')
    title(sprintf('%.0f kHz',Freq/1e3))
    caxis([-55 -35])
    axis equal;
    shading interp;
    
    new_echo_figure(main_figure,'Name','Beam Pattern','Tag',sprintf('Bp2%.0f',uui));
    surf(XI, YI, ZI)
    hold on;
    %surf(XI, YI, ZI_comp)
    axis equal
    grid on;
    colormap(jet)
    zlabel('TS (dB re 1m^2)')
    xlabel('Port/stbd angle (\circ)')
    ylabel('Fore/aft angle (\circ)')
    title(sprintf('%.0f kHz',Freq/1e3))
    zlim([-55 -35])
    shading interp;
    
    if uui==idx_freq
        hold(ah,'on');
        plot(ah,idx_pings,range(idx_peak),'.r','markersize',5);
    end
    drawnow;
    
    if strcmp(layer.Transceivers(uui).Mode,'FM')
        
        set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',length(idx_pings), 'Value',0);
        load_bar_comp.status_bar.setText(sprintf('Processing TS estimation Frequency %.0fkz',layer.Transceivers(uui).Params.Frequency(1)/1e3));
        [cal_path,~,~]=fileparts(layer.Filename{1});
        file_cal=fullfile(cal_path,['Curve_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
        
        
        
        if exist(file_cal,'file')>0
            disp('Calibration file loaded.');
            cal=load(file_cal);
        else
            disp('No calibration file');
            cal=[];
        end
        
        
        for kk=1:length(idx_pings)
            [Sp_f(:,kk),Compensation_f(:,kk),f_vec(:,kk)]=processTS_f_v2(layer.Transceivers(uui),layer.EnvData,idx_pings(kk),range(idx_peak(kk)),2,cal,[]);
            set(load_bar_comp.progress_bar,'Value',kk);
        end
        
        
        
        BeamWidthAlongship_f_th=2*acosd(1-(f_vec(:,kk)/Freq).^-2*(1-cosd(layer.Transceivers(uui).Config.BeamWidthAlongship/2)));
        BeamWidthAthwartship_f_th=2*acosd(1-(f_vec(:,kk)/Freq).^-2*(1-cosd(layer.Transceivers(uui).Config.BeamWidthAthwartship/2)));
        
        
        BeamWidthAlongship_f_fit=nan(1,size(f_vec,1));
        BeamWidthAthwartship_f_fit=nan(1,size(f_vec,1));
        offset_Alongship=nan(1,size(f_vec,1));
        offset_Athwartship=nan(1,size(f_vec,1));
        peak=nan(1,size(f_vec,1));
        exitflag=nan(1,size(f_vec,1));
        
        set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',size(f_vec,1), 'Value',0);
        load_bar_comp.status_bar.setText(sprintf('Processing BeamWidth estimation Frequency %.0fkz',layer.Transceivers(uui).Params.Frequency(1)/1e3));
        
        
        for tt=1:size(f_vec,1)
            [offset_Alongship(tt), BeamWidthAlongship_f_fit(tt), offset_Athwartship(tt), BeamWidthAthwartship_f_fit(tt), ~, peak(tt), exitflag(tt)]...
                =fit_beampattern(Sp_f(tt,:), AcrossAngle_sph, AlongAngle_sph,mean([BeamWidthAlongship_f_th(tt), BeamWidthAthwartship_f_th(tt)]), mean([BeamWidthAlongship_f_th(tt), BeamWidthAthwartship_f_th(tt)]));
            set(load_bar_comp.progress_bar,'Value',kk);
        end
        
        
        new_echo_figure(main_figure,'Name','BeamWidth','Tag',sprintf('Bwidth%.0f',uui));
        hold on;
        plot(f_vec(:,1)/1e3,BeamWidthAlongship_f_fit,'-g','linewidth',2);
        plot(f_vec(:,1)/1e3,BeamWidthAlongship_f_th,'-k','linewidth',2);
        plot(f_vec(:,1)/1e3,BeamWidthAthwartship_f_fit,'-r','linewidth',2);
        plot(f_vec(:,1)/1e3,BeamWidthAthwartship_f_th,'-b','linewidth',2);
        xlabel('Frequency (kHz)')
        ylabel('BeamWidth(deg)')
        legend('Measured Alongship Beamwidth','Theoritical Alongship Beamwidth','Measured Athwardship Beamwidth','Theoritical Athwardship Beamwidth');
        
        grid on;
        drawnow;
        ylim([nanmin(BeamWidthAthwartship_f_th)*0.7 nanmax(BeamWidthAthwartship_f_th)*1.3]);
        
        [cal_path,~,~]=fileparts(layer.Filename{1});
        file_cal=fullfile(cal_path,['Curve_EBA_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
        
        
        freq_vec=f_vec(:,1);
        
        
        options.Interpreter = 'tex';
        % Include the desired Default answer
        options.Default = 'No thank you';
        options.WindowStyle = 'modal';
        % Constructt a questdlg with two options
        qstring=sprintf('Do you want to save those results for frequency %.0fkHz',Freq/1e3);
        choice = questdlg(qstring, ...
            'Calibration', ...
            'Yes','No thank you',options);
        % Handle response
        switch choice
            case 'No thank you'
                return;
        end
        
        save(file_cal,'BeamWidthAlongship_f_fit','BeamWidthAlongship_f_th','BeamWidthAthwartship_f_fit','BeamWidthAthwartship_f_th','freq_vec');
        
        clear Sp_f Compensation_f f_vec
        
    else
        close(TS_fig);
        close(BP_fig_1);
        close(BP_fig);
        fprintf('%s not in  FM mode\n',layer.Transceivers(uui).Config.ChannelID);
    end
end
setappdata(main_figure,'Layer',layer);
hide_status_bar(main_figure);
loadEcho(main_figure);
end

