function [amp_est,across_est,along_est,bs_bottom]=detec_bottom_bathymetric(Sp,AlongPhi,AcrossPhi,Range,Fs,PulseLength,thr_bottom,thr_echo,r_min)
DEBUG=1;

[nb_samples,nb_pings]=size(Sp);

AcrossPhi=AcrossPhi/180*pi;
AlongPhi=AlongPhi/180*pi;

Np=round(PulseLength*Fs);
bs_bottom=nan(2*Np+1,nb_pings);
idx_r_max=nb_samples;

[~,idx_r_min]=nanmin(abs(r_min-Range));
idx_r_min=nanmax(idx_r_min,10);
idx_r_min=nanmin(idx_r_min,nb_samples);

%RingDown=Sp(3,:);
Sp(1:idx_r_min,:)=nan;

Range_mat=repmat(Range,1,nb_pings);
Samples_mat=repmat((1:nb_samples)',1,nb_pings);


%First let's find the bottom...
heigh_b_filter=20*Np+1;

BS=Sp-10*log10(Range_mat);
BS(isnan(BS))=-999;
BS_mask_ori=((filter2(ones(3,3),BS>-900,'same'))<=2);
BS(BS_mask_ori)=-999;

BS_lin_ori=10.^(BS/10);

% idx_ringdown=analyse_ringdown(RingDown);
% BS(:,~idx_ringdown)=-999;


BS_lin=10.^(BS/10);
BS_lin(isnan(BS_lin))=0;

b_filter=1;

B_filter=gausswin(heigh_b_filter)*gausswin(b_filter)';
BS_filtered_bot_lin=(abs(filter2_perso(B_filter,BS_lin)));
BS_filtered_bot_lin(1:idx_r_min,:)=nan;
BS_filtered_bot_lin(idx_r_max+1:nb_samples,:)=nan;


BS_filtered_bot=10*log10(BS_filtered_bot_lin);
BS_filtered_bot_lin(isnan(BS_filtered_bot_lin))=0;

cumsum_BS=cumsum((BS_filtered_bot_lin));
cumsum_BS(cumsum_BS<0)=nan;
diff_cum_BS=diff(10*log10(cumsum_BS));
diff_cum_BS(1:nanmin(idx_r_min+heigh_b_filter,nb_samples),:)=0;
diff_cum_BS(isnan(diff_cum_BS))=0;

[~,idx_max_diff_cum_BS]=nanmax(diff_cum_BS);

idx_start=nanmax(idx_max_diff_cum_BS,idx_r_min);
idx_end=nanmin(idx_max_diff_cum_BS+10*heigh_b_filter,idx_r_max);

Bottom_region=Samples_mat>=repmat(idx_start,nb_samples,1)&Samples_mat<=repmat(idx_end,nb_samples,1);

Max_BS=repmat(nanmax(BS_filtered_bot),size(BS_filtered_bot,1),1);

Bottom_region=find_cluster(Bottom_region&(BS_filtered_bot>thr_bottom&BS_filtered_bot>Max_BS+thr_echo),round(heigh_b_filter/2));

Bottom_reg_ext=((BS_filtered_bot>thr_bottom&BS_filtered_bot>Max_BS+thr_echo));

if nansum(Bottom_reg_ext(:))>=0
    
    temp_bs=BS_filtered_bot;
    temp_bs(~Bottom_region)=nan;
    [~,idx_ping]=nanmax(lin_space_mean(temp_bs));
    loop_idx=[idx_ping+1:nb_pings idx_ping:-1:1];
    for i=2:nb_pings
        if nansum(Bottom_region(:,loop_idx(i-1)).*Bottom_region(:,loop_idx(i)))==0 && loop_idx(i)~=idx_ping && nansum(Bottom_reg_ext(:,loop_idx(i)))>heigh_b_filter
            idx_reg_com=find(Bottom_region(:,loop_idx(i-1)).*Bottom_reg_ext(:,loop_idx(i)));
            if isempty(idx_reg_com)
                idx_reg_com=floor(nanmin(abs(find(Bottom_reg_ext(:,loop_idx(i)))-nanmean(find(Bottom_region(:,loop_idx(i-1)))))));
            end
            if isempty(idx_reg_com)||nansum(isnan(idx_reg_com))==length(idx_reg_com)
                idx_reg_com=find(find_cluster(Bottom_reg_ext(:,loop_idx(i))+Bottom_region(:,loop_idx(i-1)),1));
            end
            if isempty(idx_reg_com)
               Bottom_region(:,loop_idx(i))=Bottom_region(:,loop_idx(i-1));
            end
            start_up=nanmin(idx_reg_com);
            start_down=nanmax(idx_reg_com);
            Bottom_region(:,loop_idx(i))=0;
            Bottom_region(idx_reg_com,loop_idx(i))=1;
            while start_up>1 && Bottom_reg_ext(start_up,loop_idx(i))==1
                Bottom_region(start_up-1,loop_idx(i))=1;
                start_up=start_up-1;
            end
            while start_down<nb_samples && Bottom_reg_ext(start_down,loop_idx(i))==1
                Bottom_region(start_down+1,loop_idx(i))=1;
                start_down=start_down+1;
            end
        elseif nansum(Bottom_region(:,loop_idx(i-1)).*Bottom_region(:,loop_idx(i)))==0 && loop_idx(i)~=idx_ping
            Bottom_region(:,loop_idx(i))=Bottom_region(:,loop_idx(i-1));
        end
    end
end

Bottom_region(:,nansum(Bottom_region)<=Np)=0;

Bottom_region=ceil(filter2_perso(ones(3,b_filter),Bottom_region));
Bottom_region=floor(filter2_perso(ones(3,b_filter),Bottom_region));

idx_bottom=repmat((1:nb_samples)',1,nb_pings);
idx_bottom(~Bottom_region)=nan;
idx_bottom(end,(nansum(idx_bottom)==0))=nb_samples;

n_eval_across=ones(1,nb_pings);
n_eval_along=ones(1,nb_pings);
delta_along=nan(1,nb_pings);
delta_across=nan(1,nb_pings);
phi_slope_along=nan(1,nb_pings);
phi_slope_across=nan(1,nb_pings);

n_eval_amp=ones(1,nb_pings);

for i=1:nb_pings
    idx_temp_1=idx_bottom(~isnan(idx_bottom(:,i)),i);
    
    if length(idx_temp_1)>8*Np
        
        BS_temp_1=BS_lin_ori(idx_temp_1,i);
        Phi_along_temp_1=AlongPhi(idx_temp_1,i);
        Phi_across_temp_1=AcrossPhi(idx_temp_1,i);
        
        [n_along_temp_1,delta_along_temp_1,phi_slope_along(i),phi_est_along]=est_phicross_fft(idx_temp_1,BS_temp_1,Phi_along_temp_1,0);
        [n_across_temp_1,delta_across_temp_1,phi_slope_across(i),phi_est_across]=est_phicross_fft(idx_temp_1,BS_temp_1,Phi_across_temp_1,0);
        
        n_eval_amp(i)=round(nansum(BS_temp_1.*(idx_temp_1))/nansum(BS_temp_1));
        
        
        idx_temp_along=idx_temp_1(sqrt(angle((exp(1i*phi_est_along).*exp(-1i*Phi_along_temp_1))).^2)<delta_along_temp_1&10*log10(BS_temp_1)>+thr_bottom);
        idx_temp_across=idx_temp_1(sqrt(angle((exp(1i*phi_est_across).*exp(-1i*Phi_across_temp_1))).^2)<delta_across_temp_1&10*log10(BS_temp_1)>=thr_bottom);
        
        
        if  length(idx_temp_along)>8*Np
            BS_along_temp=BS_lin_ori(idx_temp_along,i);
            Phi_along_temp=AlongPhi(idx_temp_along,i);
            [n_along_temp,delta_along(i),phi_slope_along(i),phi_est_along]=est_phicross_fft(idx_temp_along,BS_along_temp,Phi_along_temp,0);
            n_eval_along(i)=n_along_temp;

        else
            idx_temp_along=idx_temp_1;
            BS_along_temp=BS_temp_1;
            Phi_along_temp=Phi_along_temp_1;
            n_eval_along(i)=n_along_temp_1;
            delta_along(i)=delta_along_temp_1;
            
        end
        
        if  length(idx_temp_across)>8*Np
            BS_across_temp=BS_lin_ori(idx_temp_across,i);
            Phi_across_temp=AcrossPhi(idx_temp_across,i);
            [n_across_temp,delta_across(i),phi_slope_across(i),phi_est_across]=est_phicross_fft(idx_temp_across,BS_across_temp,Phi_across_temp,0);
            n_eval_across(i)=n_across_temp;
          
        else
            idx_temp_across=idx_temp_1;
            BS_across_temp=BS_temp_1;
            Phi_across_temp=Phi_across_temp_1;
            n_eval_across(i)=n_across_temp_1;
            delta_across(i)=delta_across_temp_1;
        end
%         dyn_phi_est_across(i)=abs(nanmax(phi_est_across)-nanmin(phi_est_across));
%         dyn_phi_est_along(i)=abs(nanmax(phi_est_along)-nanmin(phi_est_along));
    end
    
    %i_display=1:500:nb_pings;
    i_display=200;
    if any(i==i_display)
        new_echo_figure([])
        clf;
        ax1=subplot(3,1,1);
        plot(idx_temp_along,Phi_along_temp/pi*180)
        hold on;
        plot(idx_temp_along,phi_est_along/pi*180,'r');
        plot(AlongPhi(:,i)/pi*180,'k');
        grid on;
        plot(n_eval_along(i),linspace(-pi,pi,nb_pings),'k','linewidth',2)
        set(gca,'fontsize',16);
        xlabel('Sample number');
        ylabel('Phase deg.');
        title(['Std Fit ' num2str(delta_along(i)/pi*180) 'deg.'])
        
        ax2=subplot(3,1,2);
        plot(idx_temp_across,Phi_across_temp/pi*180)
        hold on;
        plot(idx_temp_across,phi_est_across/pi*180,'r');
        plot(AcrossPhi(:,i)/pi*180,'k');
        grid on;
        plot(n_eval_across(i),linspace(-pi,pi,nb_pings),'k','linewidth',2)
        set(gca,'fontsize',16);
        xlabel('Sample number');
        ylabel('Phase deg.');
        title(['Std Fit ' num2str(delta_across(i)/pi*180) 'deg.'])
        
        ax3=subplot(3,1,3);
        plot(idx_temp_along,10*log10(BS_along_temp))
        hold on;
        plot(n_eval_along(i),linspace(0,nanmax(10*log10(BS_along_temp)),nb_pings),'k','linewidth',2)
        plot(10*log10(BS_lin_ori(:,i)),'k');
        grid on;
        set(gca,'fontsize',16);
        xlabel('Sample number');
        ylabel('BS(dB).');
        title(['Along: Ping Number ' num2str(i)])
        %pause;
        linkaxes([ax1,ax2,ax3],'x');
       
       
        
        
    end
    
end

n_eval_amp(isnan(n_eval_amp))=1;
n_eval_across(isnan(n_eval_across))=1;
n_eval_along(isnan(n_eval_along))=1;

n_eval_across((n_eval_across)>nb_samples|(n_eval_across)<=0)=1;
n_eval_along((n_eval_along)>nb_samples|(n_eval_along)<=0)=1;

dr=nanmean(diff(Range));
phi_slope_across=phi_slope_across/dr;
phi_slope_along=phi_slope_across/dr;

amp_est=struct('idx',n_eval_amp,'range',Range(round(n_eval_amp)));

across_est=struct('idx',n_eval_across,'range',Range(round(n_eval_across)),'delta',delta_across,'slope',phi_slope_across);

along_est=struct('idx',n_eval_along,'range',Range(round(n_eval_along)),'delta',delta_along,'slope',phi_slope_along);



end


