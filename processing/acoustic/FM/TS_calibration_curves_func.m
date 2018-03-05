function TS_calibration_curves_func(main_figure)

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;

[~,idx_freq]=layer.get_trans(curr_disp);

calibration_tab_comp=getappdata(main_figure,'Calibration_tab');
sphere_list=get(calibration_tab_comp.sphere,'String');
sph=get_sph_params(sphere_list{get(calibration_tab_comp.sphere,'value')});


att_list=get(calibration_tab_comp.att_model,'String');
att_model=att_list{get(calibration_tab_comp.att_model,'value')};

f_vec_save=[];

list_freq_str=cell(1,length(layer.Frequencies));
if numel(list_freq_str)>1
    for ki=1:length(layer.Frequencies)
        list_freq_str{ki}=num2str(layer.Frequencies(ki),'%.0f');
    end
    
    [select,val] = listdlg('ListString',list_freq_str,'SelectionMode','Multiple','Name','Choose Frequencies to calibrate',...
        'PromptString','Choose Frequencies to calibrate','InitialValue',1:length(layer.Frequencies));
    
    if val==0||isempty(select)
        return;
    end
else
    select=1;
end

for uui=select
    trans_obj=layer.Transceivers(uui);
    
    range=double(trans_obj.get_transceiver_range());
    ping_num=trans_obj.get_transceiver_pings();
    
    mask=trans_obj.mask_from_regions();
    
    
    [samples_m,~]=find(mask);
    
    r_min=nanmin(range(samples_m));
    r_max=nanmax(range(samples_m));
    
    if isempty(r_min)||isempty(r_max)
        continue;
    end
    
    bad_trans=zeros(size(ping_num));
    bad_trans(trans_obj.Bottom.Tag==0)=1;
    mask(:,bad_trans==1)=0;
    
    idx_r=find(range<=r_max&range>=r_min);
    
    if isempty(idx_r)
        [~,idx_r]=nanmin(abs(range-r_max));
    end
    
    idx_pings=find(nansum(mask)>0);
    
    
    Sp=trans_obj.Data.get_datamat('Sp');
    Sp(mask==0)=nan;
    AlongAngle=trans_obj.Data.get_datamat('AlongAngle');
    AcrossAngle=trans_obj.Data.get_datamat('AcrossAngle');
    
    Freq=(trans_obj.Config.Frequency);

    [nb_samples,~]=size(AcrossAngle);
    
    sphere_ts = spherets(2*pi*Freq/layer.EnvData.SoundSpeed,sph.radius, layer.EnvData.SoundSpeed, ...
    sph.lont_c, sph.trans_c, sph.rho_water, sph.rho);
    Sp_red=Sp(idx_r,idx_pings);
    Sp_red(Sp_red>sphere_ts+20)=nan;
 
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
    range_sph_old=range(idx_peak);
    
    t=layer.EnvData.Temperature;
    t_sphere=layer.EnvData.Temperature;
    s_sphere=layer.EnvData.Salinity;
    s=layer.EnvData.Salinity;
    
    d=nanmean(range(range<nanmean(range_sph_old)));
    
    density_at_sphere = seawater_dens(s_sphere, layer.EnvData.Temperature, nanmean(range_sph_old));

    c_at_sphere = seawater_svel_un95(s_sphere, t_sphere, nanmean(range_sph_old));
    
    % mean parameters over range from transducer to the sphere
    c = seawater_svel_un95(s, t, d);
    
    if Freq>120000&&strcmp(att_model,'Doonan et al (2003)')
        att_model='Francois & Garrison (1982)';
    end
    alpha=trans_obj.Params.Absorption(1)*1e3;
    
    if get(calibration_tab_comp.att_over,'value')==0
        switch att_model
            case 'Doonan et al (2003)'
                att_m='doonan';
            case 'Francois & Garrison (1982)'
                att_m='fandg';
        end
    else
        att_m=[];
    end
   
    sphere_ts = spherets(2*pi*Freq/layer.EnvData.SoundSpeed,sph.radius, c_at_sphere, ...
        sph.lont_c, sph.trans_c, density_at_sphere, sph.rho);
    [path_out,~]=fileparts(layer.Filename{1});
    log_file=fullfile(path_out,['cal_log' num2str(layer.Frequencies(uui)) '.txt']);
    fid=[1 fopen(log_file,'w')];
    
    % print out the parameters
    for ifi=1:length(fid)
        if fid(ifi)>=0
            fprintf(fid(ifi),['sound speed at sphere = ' num2str(c_at_sphere) ' m/s\n']);
            fprintf(fid(ifi),['density at sphere = ' num2str(density_at_sphere) ' kg/m^3\n']);
            fprintf(fid(ifi),['mean Absorption = ' num2str(alpha) ' dB/km\n']);
            fprintf(fid(ifi),['mean sound speed = ' num2str(c) ' m/s\n']);
            fprintf(fid(ifi),['sphere TS = ' num2str(sphere_ts) ' dB\n']);
            if ifi>1
                fclose(fid(ifi));
            end
        end
        
    end
        
    layer.apply_soundspeed(c);
    trans_obj.apply_absorption(alpha/1e3);
    range=double(trans_obj.get_transceiver_range());
    range_sph=range(idx_peak);
    
    update_axis_panel(main_figure,0);
    update_calibration_tab(main_figure);
    display_bottom(main_figure);
    display_tracks(main_figure);
    display_file_lines(main_figure);
    display_regions(main_figure,'all');
    display_survdata_lines(main_figure);
    layer=getappdata(main_figure,'Layer');
    set_alpha_map(main_figure,'main_or_mini',union({'main','mini'},layer.ChannelID));
    order_stacks_fig(main_figure);


    compensation = simradBeamCompensation(trans_obj.Config.BeamWidthAlongship, trans_obj.Config.BeamWidthAthwartship, AlongAngle_sph, AcrossAngle_sph);
    
    [phi, ~] = simradAnglesToSpherical(AlongAngle_sph, AcrossAngle_sph);
    
    %idx_low=compensation>18|(Sp_sph>-30)|idx_peak==idx_r(1);
    
    est_ts = sphere_ts-compensation;
    
    idx_low=idx_peak==idx_r(1)|abs(Sp_sph-est_ts)>12|...
        AlongAngle_sph>trans_obj.Config.BeamWidthAlongship|AcrossAngle_sph>trans_obj.Config.BeamWidthAthwartship;
    
    AlongAngle_sph(idx_low)=[];
    AcrossAngle_sph(idx_low)=[];
    Sp_sph(idx_low)=[];
    idx_peak(idx_low)=[];
    idx_pings(idx_low)=[];
    phi(idx_low)=[];
    compensation(idx_low)=[];
    range_sph(idx_low)=[];
    
    if isempty(AlongAngle_sph)
        disp('Not enough echoes');
        continue;
    end
    
    if idx_freq==uui
        plot(ah,trans_obj.get_transceiver_pings(idx_pings),idx_peak,'.k','linewidth',2);
    end
    
    
    if strcmp(trans_obj.Mode,'FM')
        
        xi=linspace(nanmin(AlongAngle_sph),nanmax(AlongAngle_sph),1000);
        yi=linspace(nanmin(AcrossAngle_sph),nanmax(AcrossAngle_sph),1000);
        
        [XI,YI]=meshgrid(xi,yi);
        ZI = griddata(AlongAngle_sph,AcrossAngle_sph,Sp_sph, XI, YI);
        
        
        new_echo_figure(main_figure,'Name',sprintf('%.0f kHz Beam Pattern',Freq/1e3),'Tag',sprintf('Bp%.0f',uui));
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
        
        
        new_echo_figure(main_figure,'Name',sprintf('%.0f kHz Beam Pattern',Freq/1e3),'Tag',sprintf('Bp2%.0f',uui));
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
        
        idx_low=(Sp_sph<=-70)|abs(phi)>1|compensation>12;
        idx_peak(idx_low)=[];
        idx_pings(idx_low)=[];
        range_sph(idx_low)=[];
        
        if idx_freq==uui;
            hold(ah,'on');
            plot(ah,idx_pings,range(idx_peak),'.r','markersize',5);
            drawnow;
        end
        
        if isempty(idx_peak)     
            disp('Not enough central echoes');
            continue;
        end
        
         set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',length(idx_pings), 'Value',0);
        load_bar_comp.status_bar.setText(sprintf('Processing TS estimation Frequency %.0fkz',trans_obj.Params.Frequency(1)/1e3));

           
        
        
        for kk=1:length(idx_pings)
            [Sp_f(:,kk),Compensation_f(:,kk),f_vec(:,kk)]=processTS_f_v2(trans_obj,layer.EnvData,idx_pings(kk),range(idx_peak(kk)),1,[],att_m);
            set(load_bar_comp.progress_bar, 'Value',kk);
        end
        
        Compensation_f(Compensation_f>6)=nan;
        
        TS_f=Sp_f+Compensation_f;
        
        TS_f_mean=10*log10(nanmean(10.^(TS_f'/10)));
        
        
        ts=nan(1,length(f_vec(:,1)));
        
        for jj=1:length(f_vec(:,1))
            ts(jj) =  spherets(2*pi*f_vec(jj,1)/layer.EnvData.SoundSpeed,sph.radius, c_at_sphere, ...
                sph.lont_c, sph.trans_c, density_at_sphere, sph.rho);
        end
        
          
        new_echo_figure(main_figure,'Name','TS','Tag',sprintf('TS%.0f',uui));
        plot(f_vec/1e3,TS_f,'b','linewidth',0.2);
        hold on;
        plot(f_vec(:,1)/1e3,TS_f_mean,'r','linewidth',2);
        plot(f_vec(:,1)/1e3,ts,'k','linewidth',2)
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
        
        g_c=trans_obj.get_current_gain();
 
        Gf_ori=g_c +10*log10(freq_vec./Freq);

        Gf=(cal_ts-th_ts)/2+Gf_ori(:)';
        
        
        options.Interpreter = 'tex';
        % Include the desired Default answer
        options.Default = 'No thank you';
        options.WindowStyle = 'modal';
        % Construct a questdlg with two options
        qstring=sprintf('Do you want to save those results for frequency %.0f kHz',Freq/1e3);
        choice = questdlg(qstring, ...
            'Calibration', ...
            'Yes','No thank you',options);
        
        % Handle response
        switch choice
            case 'No thank you'
                
            otherwise
                save(file_cal,'freq_vec','cal_ts','th_ts','Gf');
        end
               
          
        clear Sp_f Compensation_f TS_f f_vec TS_f_mean
    else
       fprintf('%s not in  FM mode\n',trans_obj.Config.ChannelID);

       process_data(trans_obj,layer.EnvData,idx_peak,idx_pings,idx_r,sphere_ts,log_file,main_figure);

    end
end


setappdata(main_figure,'Layer',layer);
hide_status_bar(main_figure);
loadEcho(main_figure);

end
