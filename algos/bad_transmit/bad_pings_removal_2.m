function [Bottom,Double_bottom_region,idx_noise_sector]=bad_pings_removal_2(Sv,Range,Fs,PulseLength,varargin)
global DEBUG

p = inputParser;

default_BS_std=6;
check_BS_std=@(x)(x>=3)&&(x<=20);


default_thr_bottom=-56;
check_thr_bottom=@(x)(x>=-120&&x<=-10);

default_thr_echo=-12;
check_thr_echo=@(x)(x>=-20&&x<=-3);

default_idx_r_min=Range(1);
check_idx_r=@(x)(x>=Range(1)&&x<=Range(end));

check_spikes=@(x)(x>=0&&x<=20);

default_idx_r_max=Range(end);
default_spikes=4;
check_shift_bot=@(x)x>=0;

addRequired(p,'Sv',@isnumeric);
addRequired(p,'Range',@isnumeric);
addRequired(p,'Fs',@isnumeric);
addRequired(p,'PulseLength',@isnumeric);
addParameter(p,'thr_bottom',default_thr_bottom,check_thr_bottom);
addParameter(p,'thr_echo',default_thr_echo,check_thr_echo);
addParameter(p,'r_min',default_idx_r_min,check_idx_r);
addParameter(p,'r_max',default_idx_r_max,check_idx_r);
addParameter(p,'BS_std',default_BS_std,check_BS_std);
addParameter(p,'BS_std_bool',true,@islogical);
addParameter(p,'thr_spikes_Above',default_spikes,check_spikes);
addParameter(p,'thr_spikes_Below',default_spikes,check_spikes);
addParameter(p,'Above',true,@(x) isnumeric(x)||islogical(x));
addParameter(p,'Below',true,@(x) isnumeric(x)||islogical(x));
addParameter(p,'burst_removal',false,@(x) isnumeric(x)||islogical(x));
addParameter(p,'shift_bot',0,check_shift_bot);

parse(p,Sv,Range,Fs,PulseLength,varargin{:});


thr_bottom=p.Results.thr_bottom;
thr_echo=p.Results.thr_echo;
r_min=p.Results.r_min;
r_max=p.Results.r_max;
BS_std=p.Results.BS_std;
BS_std_bool=p.Results.BS_std_bool;
thr_spikes_Above=p.Results.thr_spikes_Above;
thr_spikes_Below=p.Results.thr_spikes_Below;
Above=p.Results.Above;
Below=p.Results.Below;
burst_removal=p.Results.burst_removal;
shift_bot=p.Results.shift_bot;

Np=round(PulseLength*Fs);
[nb_samples,nb_pings]=size(Sv);



%First let's find the bottom...


[Bottom,Double_bottom_region,BS_bottom,idx_bottom,idx_ringdown]=detec_bottom_algo_v2(Sv,...
    Range,...
    Fs,...
    PulseLength,...
    'thr_bottom',thr_bottom,...
    'thr_echo',thr_echo,...
    'r_min',r_min,...
    'r_max',r_max,...
    'shift_bot',shift_bot);


start_sample=nanmin([50 nb_samples]);
Sv(1:start_sample,:)=nan;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Quick BS Analysis if asked%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b_filter=3:2:7;
if BS_std_bool
    
    BS_bottom(Bottom<start_sample)=nan;
    
    BS_bottom_analysis=BS_bottom;
    BS_bottom_analysis(isnan(Bottom))=nan;
    %
    % BS_std_up=-20*log10((sqrt(4/pi-1)));
    % BS_std_dw=20*log10((sqrt(4/pi-1)));
    
    BS_std_up=BS_std;
    BS_std_dw=-BS_std;
    
    Mean_BS=nan(length(b_filter),nb_pings);
    
    for j=1:length(b_filter)
        Mean_BS(j,:)=20*log10(filter_nan(ones(1,b_filter(j)),10.^(BS_bottom_analysis/20))./filter_nan(ones(1,b_filter(j)),ones(1,length(BS_bottom))));
        idx_temp=((BS_bottom_analysis-Mean_BS(j,:))<=BS_std_up&(BS_bottom_analysis-Mean_BS(j,:))>=BS_std_dw);
        BS_bottom_analysis(~idx_temp)=nan;
        
        if DEBUG
            figure();
            clf;
            plot(BS_bottom-Mean_BS(j,:),'r');
            hold on;
            plot(BS_bottom_analysis-Mean_BS(j,:));
            plot(BS_std_up*ones(1,nb_pings),'k','linewidth',2)
            plot(BS_std_dw*ones(1,nb_pings),'k','linewidth',2)
            grid on;
            set(gca,'fontsize',16);
            xlabel('Ping Number');
            ylabel('BS(dB)');
            ylim([-20 20])
            title(['Filter size ' num2str(b_filter(j))])
            pause;
            close gcf;
        end
    end
    
    idx_bottom_bs_eval=~isnan(BS_bottom_analysis);
    idx_bottom_bs_eval(nansum(Double_bottom_region)==0)=1;
    idx_bottom_bs_eval(isnan(Bottom))=1;
    idx_bottom_bs_eval(isnan(BS_bottom))=1;
else
    idx_bottom_bs_eval=ones(1,nb_pings);
end

Bottom(nansum(Double_bottom_region)==0)=nan;
idx_bottom(nansum(Double_bottom_region)==0)=nan;

noisy_pings=msgbox('Removal of noisy pings. This box will close when finished...','Removal of noisy pings');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Removal of noisy pings%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

idx_spikes_Below=ones(1,nb_pings);
idx_spikes_Above=ones(1,nb_pings);



if Above||Below
    
    idx_noise_analysis_above=nan(nb_samples,nb_pings);
    idx_noise_analysis_below=nan(nb_samples,nb_pings);
    [I_bottom,J_bottom]=find(~isnan(idx_bottom));
    I_bottom(I_bottom>nb_samples)=nb_samples;
    J_double_bottom=[J_bottom ; J_bottom ; J_bottom];
    I_double_bottom=[I_bottom ; 2*I_bottom ; 2*I_bottom+1];
    I_double_bottom(I_double_bottom > nb_samples)=nan;
    idx_double_temp=I_double_bottom(~isnan(I_double_bottom))+nb_samples*(J_double_bottom(~isnan(I_double_bottom))-1);
    
    idx_double_bottom=repmat((1:nb_samples)',1,nb_pings);
    idx_samples=nan(nb_samples,nb_pings);
    
    idx_samples(idx_double_temp)=1;
    
    idx_double_bottom=idx_samples.*idx_double_bottom;
    
    if Above
        idx_noise_analysis_above=double(repmat((1:nb_samples)',1,nb_pings)<repmat(nanmin(idx_bottom),nb_samples,1));
        idx_noise_analysis_above(~idx_noise_analysis_above)=nan;
        idx_noise_analysis_above(1:start_sample,:)=nan;
    end
    
    if Below
        idx_noise_analysis_below=double(repmat((1:nb_samples)',1,nb_pings)>repmat(nanmax(idx_bottom),nb_samples,1)&isnan(idx_double_bottom));
        idx_noise_analysis_below(~idx_noise_analysis_below)=nan;
        idx_noise_analysis_below(1:start_sample,:)=nan;
    end
    
    idx_bottom_temp=double(~isnan(idx_bottom));
    idx_bottom_temp(idx_bottom_temp==0)=nan;
    
    Sv_lin=10.^(Sv/20);
    Sv_bottom_max=nanmax(20*log10(filter2(ones(2*Np,b_filter(end)),Sv_lin,'same').*idx_bottom_temp/(3*Np*b_filter(end))));
    Norm_Val=Sv-repmat(Sv_bottom_max,nb_samples,1);
    
    
    Norm_Val(Norm_Val==Inf)=nan;
    
    
    %%%%%%%%Version with sliding pdf%%%%%
    win=nanmin(300,nb_pings);
    bins=120;
    spc=round(win/2);
    x_data=(1:nb_pings);
    
    
    
    thr_min_above=nan(1,nb_pings);
    thr_max_above=nan(1,nb_pings);
    thr_min_below=nan(1,nb_pings);
    thr_max_below=nan(1,nb_pings);
    
    
    if Above
        [pdf_above,x_above,y_above,~]= sliding_pdf(x_data,Norm_Val.*idx_noise_analysis_above,win,bins,spc,0);
        if min(size(y_above))>1
            [~,grad_y_above]=gradient(y_above);
        else
            grad_y_above=gradient(y_above);
        end
        [~,idx_min_above]=(nanmin(abs(cumsum(pdf_above.*grad_y_above)-thr_spikes_Above/100)));
        [~,idx_max_above]=(nanmin(abs(cumsum(pdf_above.*grad_y_above)-(1-thr_spikes_Above/100))));
        for i=1:nb_pings
            [~,idx_x]=nanmin(abs(i-x_above(1,:)));
            thr_min_above(i)=y_above(idx_min_above(idx_x),idx_x);
            thr_max_above(i)=y_above(idx_max_above(idx_x),idx_x);
        end
    end
    
    if Below
        [pdf_below,x_below,y_below,~]= sliding_pdf(x_data,Norm_Val.*idx_noise_analysis_below,win,bins,spc,0);
        if min(size(y_above))>1
            [~,grad_y_below]=gradient(y_below);
        else
            grad_y_below=gradient(y_below);
        end
        [~,idx_min_below]=(nanmin(abs(cumsum(pdf_below.*grad_y_below)-thr_spikes_Below/100)));
        [~,idx_max_below]=(nanmin(abs(cumsum(pdf_below.*grad_y_below)-(1-thr_spikes_Below/100))));
        
        for i=1:nb_pings
            [~,idx_x]=nanmin(abs(i-x_below(1,:)));
            thr_min_below(i)=y_below(idx_min_below(idx_x),idx_x);
            thr_max_below(i)=y_below(idx_max_below(idx_x),idx_x);
        end
    end
    
    
    
    thr_spikes=0.1;
    
    idx_below_max=(Norm_Val.*idx_noise_analysis_below)>=repmat(thr_max_below,nb_samples,1);
    idx_below_min=(Norm_Val.*idx_noise_analysis_below)<=repmat(thr_min_below,nb_samples,1);
    thr_spikes_Below_vec=nansum(idx_noise_analysis_below).*(thr_spikes_Below/100+thr_spikes);
    
    idx_above_max=(Norm_Val.*idx_noise_analysis_above)>=repmat(thr_max_above,nb_samples,1);
    idx_above_min=(Norm_Val.*idx_noise_analysis_above)<=repmat(thr_min_above,nb_samples,1);
    thr_spikes_Above_vec=nansum(idx_noise_analysis_above).*(thr_spikes_Above/100+thr_spikes);
    
    idx_spikes_Below=nansum(idx_below_max)<thr_spikes_Below_vec&nansum(idx_below_min)<thr_spikes_Below_vec;
    idx_spikes_Above=nansum(idx_above_max)<thr_spikes_Above_vec&nansum(idx_above_min)<thr_spikes_Above_vec;
    
    idx_spikes_Below(nansum(idx_noise_analysis_below)==0)=1;
    idx_spikes_Above(nansum(idx_noise_analysis_above)==0)=1;
    idx_spikes_Above(Bottom<=start_sample)=1;
    
    if DEBUG
        figure()
        subplot(2,1,1)
        imagesc(idx_below_max|idx_above_max);
        subplot(2,1,2)
        imagesc(idx_below_min|idx_above_min);
        
        figure();
        subplot(2,1,1)
        plot(thr_min_above);
        hold on;
        plot(thr_max_above,'r')
        grid on;
        subplot(2,1,2)
        plot(thr_min_below);
        hold on;
        plot(thr_max_below,'r')
        grid on;
        
        
        figure()
        subplot(2,1,1)
        plot(nansum(idx_above_max),'r');
        hold on;
        plot(nansum(idx_above_min));
        plot(thr_spikes_Above_vec,'k');
        plot(nansum(idx_noise_analysis_above).*(thr_spikes_Above/100),'--k')
        subplot(2,1,2)
        plot(nansum(idx_below_max),'r');
        hold on;
        plot(nansum(idx_below_min));
        plot(thr_spikes_Below_vec,'k');
        plot(nansum(idx_noise_analysis_below).*(thr_spikes_Below/100),'--k')
    end
    
end

%%%%%%%% Morpho Analysis for removal of short burst of noise%%%%%%%%%%%%%
idx_noise_burst=zeros(1,nb_pings);

if burst_removal
    heigh_burst=10*Np;
    B_filter_2=ones(heigh_burst,1);
    Sv_temp=Sv;
    Sv_temp(repmat((1:nb_samples)',1,nb_pings)>repmat(nanmin(idx_bottom),nb_samples,1))=nan;
    Sv_filtered=20*log10(abs(filter2(B_filter_2,10.^(Sv_temp/20),'same'))./filter2(B_filter_2,ones(size(Sv)),'same'));
    
    Sv_filtered_unmean=Sv_filtered-repmat(20*log10(nanmean(10.^(Sv_filtered/20))),nb_samples,1);
    
    thr_burst_vect=10:2:20;
    thr_rem_vect=10.^linspace(log10(3*heigh_burst),log10(heigh_burst),length(thr_burst_vect));
    
    for  i=1:length(thr_burst_vect)
        thr_burst=thr_burst_vect(i);
        thr_rem=thr_rem_vect(i);
        mask_sv_ori=Sv_filtered_unmean>thr_burst;
        mask_sv=ceil(filter2(ones(heigh_burst,1),mask_sv_ori,'same')./filter2(ones(heigh_burst,1),ones(size(Sv)),'same'));
        mask_sv=floor(filter2(ones(heigh_burst,1),mask_sv,'same')./filter2(ones(heigh_burst,1),ones(size(Sv)),'same'));
        mask_sv_erode=floor(filter2(ones(1,2),mask_sv,'same')./filter2(ones(1,2),ones(size(Sv)),'same'));
        mask_sv_dilate=ceil(filter2(ones(2,3),mask_sv_erode,'same')./filter2(ones(2,3),ones(size(Sv)),'same'));
        mask_sv_f=mask_sv_ori&~mask_sv_dilate;
        %mask_sv_f=floor(filter2(ones(heigh_burst,1),mask_sv_f,'same')./filter2(ones(heigh_burst,1),ones(size(Sv)),'same'));
        idx_noise_burst=nansum(mask_sv_f)<thr_rem&idx_noise_burst;
        
        if DEBUG
            figure();
            plot(nansum(mask_sv_ori),'g')
            hold on;
            plot(nansum(mask_sv_f));
            hold on;
            plot(thr_rem*ones(1,nb_pings),'r')
            grid on;
            set(gca,'fontsize',16);
            xlabel('Ping Number')
            ylabel('Number of "bad" samples')
            pause
            close (gcf)
        end
    end
else
    idx_noise_burst=ones(1,nb_pings);
end


%%%%%%And compile the final vector designing the bad pings%%%%%%%%%%%%%%%%
idx_noise_sector=~(idx_spikes_Below&idx_spikes_Above&idx_bottom_bs_eval&idx_ringdown&idx_noise_burst);
%%%%%%%%%%%%%Remove isolated "good" pings%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idx_noise_sector_filter=filter2(ones(1,9),idx_noise_sector)./filter2(ones(1,9),ones(size(idx_noise_sector)));
idx_noise_sector(idx_noise_sector_filter>=7/9)=1;


bad_pings_percent=nansum(idx_noise_sector)/nb_pings*100;
disp([num2str(bad_pings_percent) '% of bad pings']);


try
    close(noisy_pings)
end

% bad_trans=figure('Position',[260,300,900,500]);
% set(bad_trans,'Name','Bad Transmit','NumberTitle','off');
% clf;
% plot((1:nb_pings),~idx_bottom_bs_eval,'-r+','linewidth',2);
% hold on;
% plot((1:nb_pings),~idx_ringdown,'-go','linewidth',2,'linewidth',2);
% plot((1:nb_pings),~idx_spikes_Above,'-cx','linewidth',2);
% plot((1:nb_pings),~idx_spikes_Below,'-kv','linewidth',2);
% plot((1:nb_pings),idx_noise_burst,'-bs','linewidth',2);
% grid on;
% set (gca,'fontsize',14);
% xlabel('Ping Number');
% legend('From BS','From RD zone','From WaterColumn Level Above','From WaterColumn Level Below','Noise burst','Location', 'SouthEast');
% ylim([-0.2 1.2])
% close(bad_trans);

end


