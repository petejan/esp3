function bs_analysis_callback(~,~,main_figure)
update_algos(main_figure);
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

phi_std_thr=20/180*pi;
trans_angle=[0 -45];%pitch roll
pos_trans=[-5;-5;-5];%dalong dacross dz
%ext_len=240;%number of points around center of the beam

roll_cal=0;
pitch_cal=0;

idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);

trans.set_position(pos_trans,trans_angle);

range=trans.Data.Range;

dr=nanmean(diff(range));

bw_mean=(trans.Config.BeamWidthAlongship+trans.Config.BeamWidthAthwartship)/4/180*pi;
t_angle=atan(sqrt(tand(trans.Config.Angles(2)).^2+tand(trans.Config.Angles(1)).^2));
z_max=range(end)*cos(t_angle);
ext_len=floor(z_max*(tan(t_angle+bw_mean)-tan(t_angle-bw_mean))/dr/3);

%time=trans.Data.Time;
number=trans.Data.Number;

bot_range=trans.Bottom.Range;

sv=trans.Data.get_datamat('sv');
[nb_samples,nb_pings]=size(sv);
time_r=(0:nb_samples-1)*trans.Params.SampleInterval;

acrossangle=trans.Data.get_datamat('acrossangle');
alongangle=trans.Data.get_datamat('alongangle');

[alongphi,acrossphi]=trans.get_phase();


idx_algo_bot=find_algo_idx(layer.Transceivers(idx_freq),'BottomDetection');

algo=layer.Transceivers(idx_freq).Algo(idx_algo_bot);

[PulseLength,~]=trans.get_pulse_length();
[amp_est,across_est,along_est]=detec_bottom_bathymetric(sv,alongphi,acrossphi,...
    layer.Transceivers(idx_freq).Data.Range,1/trans.Params.SampleInterval(1),PulseLength,algo.Varargin.thr_bottom,algo.Varargin.thr_echo,algo.Varargin.r_min);

figure();
a1=subplot(2,1,1);
plot(number,bot_range,'r','linewidth',2);
hold on;
plot(number,amp_est.range,'g','linewidth',2);
plot(number(across_est.idx~=1),across_est.range(across_est.idx~=1),'k','linewidth',2);
plot(number(along_est.idx~=1),along_est.range(along_est.idx~=1),'y','linewidth',2);
grid on;
xlabel('Ping Number');
ylabel('Range (m)')
axis ij
a2=subplot(2,1,2);
plot(number(across_est.idx~=1),across_est.delta(across_est.idx~=1)/pi*180,'k','linewidth',2);
hold on;
plot(number(along_est.idx~=1),along_est.delta(along_est.idx~=1)/pi*180,'y','linewidth',2);
grid on;
xlabel('Ping Number');
ylabel('\delta \phi (m)')
linkaxes([a1 a2],'x')


true_idx_bottom=across_est.idx;
true_idx_bottom(across_est.idx==1)=nan;
true_idx_bottom(across_est.delta>phi_std_thr)=nan;
idx_nan=isnan(true_idx_bottom);
idx_along_add=along_est.delta(idx_nan)<phi_std_thr;
true_idx_bottom(idx_nan(idx_along_add))=along_est.idx(idx_nan(idx_along_add));

idx_nan=isnan(true_idx_bottom);
true_idx_bottom(idx_nan)=amp_est.idx(idx_nan);
true_idx_bottom(true_idx_bottom==1)=nan;

true_idx_bottom=round(true_idx_bottom);

straight_range_bottom=nan(size(true_idx_bottom));
straight_range_bottom(~isnan(true_idx_bottom))=range(true_idx_bottom(~isnan(true_idx_bottom)));

true_time_bottom=nan(size(true_idx_bottom));
true_time_bottom(~isnan(true_idx_bottom))=time_r(true_idx_bottom(~isnan(true_idx_bottom)));

time_recept=true_time_bottom/(24*60*60)+trans.Data.Time;
time_recept(isnan(time_recept))=trans.Data.Time(isnan(time_recept));
time_trans=trans.Data.Time;

att_trans=layer.AttitudeNav.resample_attitude_nav_data(time_trans);
Pitch= att_trans.Pitch+pitch_cal;
Roll= att_trans.Roll+roll_cal;
Heave= att_trans.Heave;

att_recept=layer.AttitudeNav.resample_attitude_nav_data(time_recept);
Pitch_r= att_recept.Pitch+pitch_cal;
Roll_r= att_recept.Roll+roll_cal;
Heave_r= att_recept.Heave;

d_pitch=Pitch_r-Pitch;
d_roll=Roll_r-Roll;

% figure();
% plot((Roll_r-nanmean(Roll_r))/nanmax(abs(Roll_r-nanmean(Roll_r))));
% hold on;
% plot((across_est.slope-nanmean(across_est.slope))/nanmax(abs(across_est.slope-nanmean(across_est.slope))));

Range_mat=repmat(range,1,nb_pings);

BS=sv+10*log10(Range_mat);

bs_bottom=nan(2*ext_len+1,nb_pings);
extended_time=nan(2*ext_len+1,nb_pings);
extended_range=nan(2*ext_len+1,nb_pings);
extended_straight_range=nan(2*ext_len+1,nb_pings);

extended_across_angle=nan(2*ext_len+1,nb_pings);
extended_along_angle=nan(2*ext_len+1,nb_pings);


for i=1:nb_pings
    if ~isnan(true_idx_bottom(i))
        idx_temp=nanmax(true_idx_bottom(i)-ext_len,1):nanmin(true_idx_bottom(i)+ext_len,nb_samples);
        bs_temp=BS(idx_temp,i);
        time_temp=time_r(idx_temp);
        range_temp=range(idx_temp);
        across_angle_temp=acrossangle(idx_temp,i);
        along_angle_temp=alongangle(idx_temp,i);
        idx=floor((-length(idx_temp)+(2*ext_len+1))/2)+1:floor((-length(idx_temp)+(2*ext_len+1))/2)+length(idx_temp);
        
        bs_bottom(idx,i)=bs_temp;
        extended_time(1:length(idx),i)=time_temp;
        extended_straight_range(1:length(idx),i)=range_temp;
        if across_est.delta(i)<phi_std_thr
            extended_across_angle(1:length(idx),i)=across_angle_temp;
        else
            extended_across_angle(1:length(idx),i)=nan;
        end
        
        if along_est.delta(i)<phi_std_thr
            extended_along_angle(1:length(idx),i)=along_angle_temp;
        else
            extended_along_angle(1:length(idx),i)=0;
        end
    end
end

BW_across=trans.Config.BeamWidthAthwartship;
BW_along=trans.Config.BeamWidthAlongship;


compensationAtt = simradBeamCompensation(BW_along, BW_across, d_pitch, d_roll);

compensation = simradBeamCompensation(BW_along, BW_across, extended_along_angle, extended_across_angle);

compensation(compensation>12)=nan;
compensationAtt(compensationAtt>12)=nan;
bs_bottom_uncomp=bs_bottom;
bs_bottom=bs_bottom+compensation+repmat(compensationAtt,size(compensation,1),1);



figure();
subplot(2,1,1)
imagesc(bs_bottom_uncomp);
title('UnCompensated BS(dB)')
xlabel('Ping Number');
ylabel('Sample');
colormap(gray)
colorbar;
caxis([-30 -10]);
subplot(2,1,2)
imagesc(bs_bottom);
title('Compensated BS(dB)')
xlabel('Ping Number');
ylabel('Sample');
colormap(gray)
colorbar;
caxis([-30 -10]);


alphamap=sv>=-80;

figure();
ax1=subplot(3,1,1);
imagesc(number,range,acrossangle);
hold on;
plot(number,bot_range,'r','linewidth',2);
plot(number,straight_range_bottom,'k','linewidth',2);
colormap(jet);
title('Across Angle (deg.)')

ax2=subplot(3,1,2);
imagesc(number,range,alongangle);
hold on;
plot(number,bot_range,'r','linewidth',2);
plot(number,straight_range_bottom,'k','linewidth',2);
colormap(jet);
title('Along Angle (deg.)')

ax3=subplot(3,1,3);
echo_sv=imagesc(number,range,sv);
hold on;
plot(number,bot_range,'r','linewidth',2);
plot(number,straight_range_bottom,'k','linewidth',2);
set(echo_sv,'AlphaData',alphamap);
colormap(jet);
caxis([-80 -40])
title('Sv (dB)')
xlabel('Ping Number');
ylabel('Range (m)')

linkaxes([ax1 ax2 ax3]);

layer.AttitudeNav.display_att();

z_temp=layer.EnvData.SVP.depth;
c_temp=layer.EnvData.SVP.soundspeed;

if isempty(z_temp)
    choice = questdlg('Do you want to continue with no SVP and constant velocity profile?', ...
        'File opening mode',...
        'Yes','No', ...
        'No');
    % Handle response
    switch choice
        case 'Yes'
            z_temp=range';
            c_temp=layer.Env.SoundSpeed*ones(size(z_temp));
        case 'No'
            return;
    end
    
    if isempty(choice)
        return;
    end
    
    layer.EnvData.set_svp(z_temp,c_temp);
    
end

[~,idx_shallow]=nanmin(abs(z_temp-5));
c_temp(z_temp<5)=c_temp(idx_shallow);


z_c=range';
c=interpn(z_temp,c_temp,z_c,'linear');

T=time_r(end);

transmit_angles=pi/2-atan(sqrt(tand(Roll_r+trans.Config.Angles(2)).^2+tand(Pitch_r+trans.Config.Angles(1)).^2));


true_z_bottom=nan(1,nb_pings);
true_r_bottom=nan(1,nb_pings);
true_range_bottom=nan(1,nb_pings);


c_at_bottom=nan(1,nb_pings);




ray_processing=waitbar(1/nb_pings,sprintf('Ping %d/%d',1,nb_pings),'Name','Ray Tracing','WindowStyle','Modal');
for i=1:nb_pings
    
    try
        waitbar(i/nb_pings,ray_processing,sprintf('Ping %d/%d',i,nb_pings),'WindowStyle','Modal');
    catch
        ray_processing=waitbar(i/nb_pings,sprintf('Ping %d/%d',i,nb_pings),'Name','Ray Tracing','WindowStyle','Modal');
    end
    
    [r_ray,t_ray,z_ray,~]=compute_acoustic_ray_path(z_c,c,0,0,0,transmit_angles(i),T);
    if ~isnan(true_time_bottom(i))
        [~,idx_time]=nanmin(abs(true_time_bottom(i)-2*t_ray));
        true_z_bottom(i)=z_ray(idx_time);
        true_r_bottom(i)=r_ray(idx_time);
        true_range_bottom(i)=sqrt(r_ray(idx_time).^2+z_ray(idx_time).^2);
        [~,idx_vel]=nanmin(abs(true_z_bottom(i)-z_c));
        c_at_bottom(i)=c(idx_vel);
        extended_range(:,i)=true_range_bottom(i)+(extended_time(:,i)-2*t_ray(idx_time))*c_at_bottom(i)/2;
    else
        true_z_bottom(i)=nan;
        true_r_bottom(i)=nan;
        true_range_bottom(i)=nan;
        c_at_bottom(i)=nan;
        extended_range(:,i)=nan(size(extended_range,1),1);
    end
end

try
    close(ray_processing);
end

figure();
hold on;
axis ij
grid on;
xlabel('R(m)');
ylabel('Depth (m)');
plot(z_c./tan(transmit_angles(end)),z_c,'b');
plot(r_ray,z_ray,'r');
title('Ray tracing for last ping...')
legend('Straight','Ray Tracing')


true_z_bottom(true_z_bottom<10)=nan;
true_x_along = true_r_bottom.*sind(Pitch_r+trans.Config.Angles(1));
true_y_across = sign(Roll_r+trans.Config.Angles(2)).*true_r_bottom.*cosd(Pitch_r+trans.Config.Angles(1));

pos_mat=nan(3,nb_pings);
trans_mov=nan(3,nb_pings);

for i=1:nb_pings
    attitude_mat_t=create_attitude_matrix(Pitch(i),Roll(i));
    attitude_mat_r=create_attitude_matrix(Pitch_r(i),Roll_r(i));
    trans_mov(:,i)=-(attitude_mat_t*trans.Config.Position-[0;0;Heave(i)])+(attitude_mat_r*trans.Config.Position-[0;0;Heave_r(i)]);
    pos_mat(:,i)=[true_x_along(i);true_y_across(i);true_z_bottom(i)]+attitude_mat_r*trans.Config.Position-[0;0;Heave_r(i)];
end


[x_uncorr,y_uncorr,z_uncorr]=angles_to_pos_v3(straight_range_bottom',zeros(size(straight_range_bottom')),zeros(size(straight_range_bottom')),...
    0,0,0,...
    trans.Config.Angles(2),trans.Config.Angles(1),trans.Config.Position(1),trans.Config.Position(2),trans.Config.Position(3));

pos_mat_extended=nan(size(extended_range,1),nb_pings,3);

[x_center,y_center,z_center]=angles_to_pos_v3(true_range_bottom',zeros(size(straight_range_bottom')),zeros(size(straight_range_bottom')),...
    Heave_r,...
    Pitch_r,...
    Roll_r,...
    trans.Config.Angles(2),trans.Config.Angles(1),trans.Config.Position(1),trans.Config.Position(2),trans.Config.Position(3));

for ii=1:size(extended_range,1)
    [x_temp,y_temp,z_temp]=angles_to_pos_v3(extended_range(ii,:),-extended_along_angle(ii,:),-extended_across_angle(ii,:),...
        Heave_r,...
        Pitch_r,...
        Roll_r,...
        trans.Config.Angles(2),trans.Config.Angles(1),trans.Config.Position(1),trans.Config.Position(2),trans.Config.Position(3));
    
    pos_mat_extended(ii,:,:)=([x_temp-x_center;y_temp-y_center;z_temp-z_center]+pos_mat)';
end

lat_ship=trans.GPSDataPing.Lat;
long_ship=trans.GPSDataPing.Long;

z_ext=-pos_mat_extended(:,:,3);
y_ext=pos_mat_extended(:,:,2);
x_ext=pos_mat_extended(:,:,1);




mask_bs=double(bs_bottom_uncomp>-30);
mask_bs=floor(filter2_perso(ones(2,2),mask_bs));
mask_bs=ceil(filter2_perso(ones(3,3),mask_bs))==1;


x_d=x_ext;
y_d=y_ext;
z_d=z_ext;

x_d(mask_bs==0)=nan;
y_d(mask_bs==0)=nan;
z_d(mask_bs==0)=nan;

r_d=sqrt(x_d.^2+y_d.^2);


dr=r_d(2:end,:)-r_d(1:end-1,:);
dz=z_d(2:end,:)-z_d(1:end-1,:);
dr(dr==0)=nan;


incident_angles_estimation=transmit_angles/pi*180-atan(nanmean(dz)./nanmean(dr))/pi*180;

figure();
plot(incident_angles_estimation)
xlabel('Ping Number')
ylabel('Incident angle estimation (deg)')

x=pos_mat(1,:);
y=pos_mat(2,:);
z=pos_mat(3,:);

figure();
aa2=subplot(3,1,1);
hold on;
plot(-z_uncorr,'r')
plot(-z,'b')
grid on;
legend('Uncorrected','Corrected')
ylabel('Depth');
aa3=subplot(3,1,2);
hold on;
plot(y_uncorr,'r')
plot(y,'b')
grid on;
legend('Uncorrected','Corrected')
ylabel('Across Distance');
aa4=subplot(3,1,3);
hold on;
plot(x_uncorr,'r')
plot(x,'b')
grid on;
legend('Uncorrected','Corrected')
ylabel('Along Distance');
linkaxes([aa2 aa3 aa4],'x');


[x_ship,y_ship,Zone]=deg2utm(lat_ship,long_ship);

heading=trans.AttitudeNavPing.Heading;%TOFIX when there is no attitude data...

Y_Bottom_ext=repmat(y_ship',size(y_ext,1),1)+y_ext.*cosd(repmat(heading,size(y_ext,1),1))+x_ext.*sind(repmat(heading,size(x_ext,1),1));%E
X_Bottom_ext=repmat(x_ship',size(x_ext,1),1)+x_ext.*cosd(repmat(heading,size(y_ext,1),1))-y_ext.*sind(repmat(heading,size(y_ext,1),1));%N

[lat_bot_ext,lon_bot_ext] = utm2degx(X_Bottom_ext(:),Y_Bottom_ext(:),repmat(Zone,size(Y_Bottom_ext,1),1));
lat_bot_ext=reshape(lat_bot_ext,size(X_Bottom_ext,1),size(X_Bottom_ext,2));
lon_bot_ext=reshape(lon_bot_ext,size(X_Bottom_ext,1),size(X_Bottom_ext,2));



figure();
h3=imagesc(bs_bottom);
title('BS')
grid on;
%axis equal;
view(2)
colormap(gray)
colorbar;
caxis([-30 -10])
set(h3,'alphadata',mask_bs)
shading interp


figure();
h3=imagesc(z_ext);
title('Depth')
colormap jet;
grid on;
%axis equal;
view(2)
colorbar;

set(h3,'alphadata',mask_bs)
shading interp


figure();
h1=pcolor(lat_bot_ext,lon_bot_ext,bs_bottom);
title('BS')
xlabel('Lat','fontsize',16)
ylabel('Long','fontsize',16)
zlabel('Depth(m)')
set(gca,'fontsize',16)
colormap jet;
grid on;
axis square;
colormap(gray)
colorbar;
shading interp
caxis([-30 -10]);
%caxis([nanmean(z_ext(mask_bs))-5,nanmean(z_ext(mask_bs))+5])
set(h1,'alphadata',mask_bs,'FaceAlpha','interp','AlphaDataMapping','scaled')
shading interp



figure();
hold on;
h=surf(lat_bot_ext,lon_bot_ext,bs_bottom,bs_bottom);
%scatter3(lat_ship(:),long_ship(:),Heave(:),8,'k');
title('BS')
xlabel('Lat','fontsize',16)
ylabel('Long','fontsize',16)
zlabel('Depth(m)')
set(gca,'fontsize',16);
colormap jet;
grid on;
axis square
caxis([-30 -10]);
colormap(gray)
colorbar;
set(h,'alphadata',mask_bs,'FaceAlpha','interp','AlphaDataMapping','scaled')
shading interp


figure();
hold on;
h1=surf(lat_bot_ext,lon_bot_ext,z_ext);
title('Depth From Ray Tracing')
xlabel('Lat','fontsize',16)
ylabel('Long','fontsize',16)
zlabel('Depth(m)')
set(gca,'fontsize',16)
colormap jet;
grid on;
axis square;
view(2)
colormap(jet)
colorbar;
shading interp
%caxis([nanmean(z_ext(mask_bs))-5,nanmean(z_ext(mask_bs))+5])
set(h1,'alphadata',mask_bs,'FaceAlpha','interp','AlphaDataMapping','scaled')
shading interp

file_outputs_def=[layer.PathToFile '\' layer.Filename(1:end-4) '_BS.csv'];
[file_outputs,path_out] = uiputfile('*.csv','Select Filename for saving output',file_outputs_def);

if ~isequal(file_outputs,0)&&~isequal(path_out,0)
    incident_angles_estimation_mat=repmat(incident_angles_estimation,size(z_ext,1),1);
    ping_number_mat=repmat(1:nb_pings,size(z_ext,1),1);
    new_struct=struct('Lat',lat_bot_ext(mask_bs),'Lon',lon_bot_ext(mask_bs),'Depth',z_ext(mask_bs),'BS',bs_bottom(mask_bs),...
        'PingNumber',ping_number_mat(mask_bs),'IncidentAngleEstimation',incident_angles_estimation_mat(mask_bs));    
    struct2csv(new_struct,fullfile(path_out,file_outputs));
    
end




end