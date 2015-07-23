function display_region_3D(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
region_tab_comp=getappdata(main_figure,'Region_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
Transceiver=layer.Transceivers(idx_freq);
list_reg = list_regions(layer.Transceivers(idx_freq));

Range_mat=repmat(layer.Transceivers(idx_freq).Data.Range,1,length(layer.Transceivers(idx_freq).Data.Number));

if ~isempty(list_reg)
    
    active_reg=Transceiver.Regions(get(region_tab_comp.tog_reg,'value'));
    %active_reg=Transceiver.Regions(ii);
    idx_pings=active_reg.Ping_ori:active_reg.Ping_ori+active_reg.BBox_w-1;
    idx_r=active_reg.Sample_ori:active_reg.Sample_ori+active_reg.BBox_h-1;
    nb_samples=length(idx_r);
    nb_pings=length(idx_pings);
    
    
    switch active_reg.Shape
        case 'Rectangular'
            Mask=ones(nb_samples,nb_pings);
        case 'Polygon'
            Mask=~isnan(active_reg.Sv_reg);
    end
    

    Sv=layer.Transceivers(idx_freq).Data.get_subdatamat('sv',idx_r,idx_pings); 
    Sp=layer.Transceivers(idx_freq).Data.get_subdatamat('sp',idx_r,idx_pings);
    
    idx_field=find_field_idx(layer.Transceivers(idx_freq).Data,'sp');
    cax=layer.Transceivers(idx_freq).Data.SubData(idx_field).CaxisDisplay;
  
    AlongAngle=layer.Transceivers(idx_freq).Data.get_subdatamat('alongangle',idx_r,idx_pings);
    
    AcrossAngle=layer.Transceivers(idx_freq).Data.get_subdatamat('acrossangle',idx_r,idx_pings);
    
    Range=Range_mat(idx_r,idx_pings);
    
    if isempty(layer.Transceivers(idx_freq).GPSDataPing.Lat) 
        return;
    end
    
    lat=layer.Transceivers(idx_freq).GPSDataPing.Lat(idx_pings);
    long=layer.Transceivers(idx_freq).GPSDataPing.Long(idx_pings);
    dist=layer.Transceivers(idx_freq).GPSDataPing.Dist(idx_pings);
    
    %m_proj('UTM','long',[175 182],'lat',[-40 -35]);
    %           x_geo=zeros(size(lat));
    %           y_geo=zeros(size(lat));
    %
    %           for i=2:length(lat)
    %             x_geo(i)=m_lldist([long(1) long(i)],[lat(1) lat(1)])*1000;
    %             y_geo(i)=m_lldist([long(1) long(1)],[lat(1) lat(i)])*1000;
    %           end
    %
    
    [x_geo,y_geo,Zone]=deg2utm(lat,long);
    
    heading_geo=layer.Transceivers(idx_freq).AttitudeNavPing.Heading(idx_pings);%TOFIX when there is no attitude data...
    pitch_geo=layer.Transceivers(idx_freq).AttitudeNavPing.Pitch(idx_pings);
    roll_geo=layer.Transceivers(idx_freq).AttitudeNavPing.Roll(idx_pings);
    heave_geo=layer.Transceivers(idx_freq).AttitudeNavPing.Heave(idx_pings);
    
    %heading_geo=[];
    if isempty(heading_geo)
        disp('No Heading Data, we''ll pretend to go north, I''ll fix it later');%TODO
        heading_geo=zeros(size(lat));
        x_geo=dist;
        y_geo=zeros(size(lat));
    end
    
    if isempty(pitch_geo)
        disp('No PRH Data, we''ll pretend everythings flat');
        roll_geo=zeros(size(lat));
        pitch_geo=zeros(size(lat));
        heave_geo=zeros(size(lat));
    end
    
    if size(heading_geo,1)>1
        heading_geo=heading_geo';
    end
    
    if size(roll_geo,1)>1
        roll_geo=roll_geo';
        pitch_geo=pitch_geo';
        heave_geo=heave_geo';
    end
    
    if size(x_geo,1)>1
        x_geo=x_geo';
        y_geo=y_geo';
    end
    
    heading=repmat(heading_geo,nb_samples,1);
    pitch=repmat(pitch_geo,nb_samples,1);
    roll=repmat(roll_geo,nb_samples,1);
    heave=repmat(heave_geo,nb_samples,1);
    
    X_mat=repmat(x_geo,nb_samples,1);
    Y_mat=repmat(y_geo,nb_samples,1);
    
    Mask=Mask&Sp>cax(1);
    
    
    compensation = simradBeamCompensation(layer.Transceivers(idx_freq).Config.BeamWidthAlongship,...
    layer.Transceivers(idx_freq).Config.BeamWidthAthwartship, AlongAngle, AcrossAngle);
    TS=Sp+compensation;
    Mask=Mask&compensation<12;
     cax_disp=[-60 -35];
     tt='Flare Echoes (TS)';

    
    %     figure();
    %     clf;
    %     m_gshhs_i('color','k');
    %     m_grid('box','fancy','tickdir','in');
    
    [Along_dist,Across_dist,Z_t]=angles_to_pos(Range,AlongAngle,AcrossAngle,heave,pitch,roll);
        
    Y_t=Y_mat+Across_dist.*cosd(heading)+Along_dist.*sind(heading);%E
    X_t=X_mat+Along_dist.*cosd(heading)-Across_dist.*sind(heading);%N
    
    [Lat_t,Lon_t] = utm2degx(X_t(:),Y_t(:),repmat(Zone,nb_samples,1));
    
    %         Lat_t=X_t;
    %         Lon_t=Y_t;
    %         lat=x_geo;
    %         long=y_geo;
    
    TS=TS(Mask(:)==1);
    Sv=Sv(Mask(:)==1);
    Lat_t=Lat_t(Mask(:)==1);
    Lon_t=Lon_t(Mask(:)==1);
    Z_t=Z_t(Mask(:)==1);
    
%     
    Bottom_z=layer.Transceivers(idx_freq).Bottom.Range(idx_pings)-heave_geo;   
    Surf=heave_geo;
    
    
    figure(1235);
    title(tt)
    hold on;
    h=scatter3(Lat_t(:),Lon_t(:),-Z_t(:),8,TS(:),'filled');
    scatter3(lat(:),long(:),-Bottom_z(:),8,'k','filled');
    scatter3(lat(:),long(:),Surf(:),8,'k');
    xlabel('Lat','fontsize',16)
    ylabel('Long','fontsize',16)
    zlabel('Depth(m)')
    set(gca,'fontsize',16);
    colormap jet;
    grid on;
    axis square
    %set(gca,'DataAspectRatio',[1,1,.3]);
    view(3)
    caxis(cax_disp);
    colorbar;
        
    
else
    return
end

end
