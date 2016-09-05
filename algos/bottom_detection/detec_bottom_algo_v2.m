function [Bottom,Double_bottom_region,BS_bottom,idx_bottom,idx_ringdown]=detec_bottom_algo_v2(trans_obj,varargin)
disp('Detecting Bottom.');
%profile on;
%Parse Arguments
p = inputParser;

default_idx_r_min=0;

default_idx_r_max=Inf;

default_thr_bottom=-30;
check_thr_bottom=@(x)(x>=-120&&x<=-10);

default_thr_echo=-12;
check_thr_echo=@(x)(x>=-20&&x<=-3);

check_shift_bot=@(x)(x>=0);


addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addParameter(p,'denoised',0,@(x) isnumeric(x)||islogical(x));
addParameter(p,'r_min',default_idx_r_min,@isnumeric);
addParameter(p,'r_max',default_idx_r_max,@isnumeric);
addParameter(p,'thr_bottom',default_thr_bottom,check_thr_bottom);
addParameter(p,'thr_echo',default_thr_echo,check_thr_echo);
addParameter(p,'shift_bot',0,check_shift_bot);
parse(p,trans_obj,varargin{:});

if p.Results.denoised>0
    Sv=trans_obj.Data.get_datamat('svdenoised');
    if isempty(Sv)
        Sv=trans_obj.Data.get_datamat('sv');
    end
else
    Sv=trans_obj.Data.get_datamat('sv');
end

Range= trans_obj.Data.get_range();
Fs=1/trans_obj.Params.SampleInterval(1);
PulseLength=trans_obj.Params.PulseLength(1);

thr_bottom=p.Results.thr_bottom;
thr_echo=p.Results.thr_echo;
r_min=nanmax(p.Results.r_min,2);
r_max=p.Results.r_max;

[nb_samples,nb_pings]=size(Sv);

Np=round(PulseLength*Fs);
[~,idx_r_max]=nanmin(abs(r_max-Range));
idx_r_max=nanmin(idx_r_max,nb_samples-1);
idx_r_max=nanmax(idx_r_max,10);

[~,idx_r_min]=nanmin(abs(r_min-Range));
idx_r_min=nanmax(idx_r_min,10);
idx_r_min=nanmin(idx_r_min,nb_samples);

RingDown=Sv(3,:);
Sv(1:idx_r_min,:)=nan;

Samples=(1:nb_samples)';

%First let's find the bottom...
heigh_b_filter=20*Np+1;

idx_ringdown=analyse_ringdown(RingDown);

BS=bsxfun(@plus,Sv,10*log10(Range));

BS(isnan(BS))=-999;
BS_mask_ori=((filter2(ones(3,3),BS>-900,'same'))<=2);
BS(BS_mask_ori)=-999;

BS_ori=BS;
BS(:,~idx_ringdown)=nan;


BS_lin=10.^(BS/10);
BS_lin(isnan(BS_lin))=0;

b_filter=nanmin(ceil(nb_pings/10),15);
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
idx_end=nanmin(idx_max_diff_cum_BS+3*heigh_b_filter,idx_r_max);


Bottom_region=bsxfun(@ge,Samples,idx_start)&bsxfun(@le,Samples,idx_end);

Max_BS=bsxfun(@gt,BS_filtered_bot,nanmax(BS_filtered_bot));
Bottom_region=find_cluster(Bottom_region&(BS_filtered_bot>thr_bottom&(BS_filtered_bot>Max_BS+thr_echo)),round(heigh_b_filter/2));

Bottom_mask=((BS_filtered_bot>thr_bottom&BS_filtered_bot>Max_BS+thr_echo)&~Bottom_region);

if nansum(Bottom_mask(:))>=0
    temp_bs=BS_filtered_bot;
    temp_bs(~Bottom_region)=nan;
    [~,idx_ping]=nanmax(10*log10(nanmean(10.^(temp_bs/10))));
    
    loop_idx=[idx_ping+1:nb_pings idx_ping:-1:1];
    for i=2:nb_pings
        if nansum(Bottom_region(:,loop_idx(i-1)).*Bottom_region(:,loop_idx(i)))==0 && loop_idx(i)~=idx_ping && nansum(Bottom_mask(:,loop_idx(i)))>heigh_b_filter
            idx_reg_com=find(Bottom_region(:,loop_idx(i-1)).*Bottom_mask(:,loop_idx(i)));
            if isempty(idx_reg_com)
                idx_reg_com=floor(nanmin(abs(find(Bottom_mask(:,loop_idx(i)))-nanmean(find(Bottom_region(:,loop_idx(i-1)))))));
            end
            if isempty(idx_reg_com)||nansum(isnan(idx_reg_com))==length(idx_reg_com)
               idx_reg_com=find(find_cluster(Bottom_mask(:,loop_idx(i))+Bottom_region(:,loop_idx(i-1)),1));
            end
            if isempty(idx_reg_com)
                Bottom_region(:,loop_idx(i))=Bottom_region(:,loop_idx(i-1));
            end
            start_up=nanmin(idx_reg_com);
            start_down=nanmax(idx_reg_com);
            Bottom_region(:,loop_idx(i))=0;
            Bottom_region(idx_reg_com,loop_idx(i))=1;
            while start_up>1 && Bottom_mask(start_up,loop_idx(i))==1
                Bottom_region(start_up-1,loop_idx(i))=1;
                start_up=start_up-1;
            end
            while start_down<nb_samples && Bottom_mask(start_down,loop_idx(i))==1
                Bottom_region(start_down+1,loop_idx(i))=1;
                start_down=start_down+1;
            end
            
        elseif nansum(Bottom_region(:,loop_idx(i-1)).*Bottom_region(:,loop_idx(i)))==0 && loop_idx(i)~=idx_ping
            Bottom_region(:,loop_idx(i))=Bottom_region(:,loop_idx(i-1));
        end
    end
end

Bottom_region(:,nansum(Bottom_region)<=Np)=0;

Bottom_region=ceil(filter2_perso(ones(1,b_filter),Bottom_region));
Bottom_region=floor(filter2_perso(ones(1,b_filter),Bottom_region));

n_permut=nanmin(floor((heigh_b_filter+1)/4),nb_samples);
Permut=[nb_samples-n_permut+1:nb_samples 1:nb_samples-n_permut];

Bottom_region=Bottom_region(Permut,:);
Bottom_region(1:n_permut,:)=0;

idx_bottom=repmat((1:nb_samples)',1,nb_pings);
idx_bottom(~Bottom_region)=nan;
idx_bottom(end,(nansum(idx_bottom)==0))=nb_samples;
Bottom_region(Bottom_region==0)=nan;


[I_bottom,J_bottom]=find(~isnan(idx_bottom));

I_bottom(I_bottom>nb_samples)=nb_samples;

J_double_bottom=[J_bottom ; J_bottom ; J_bottom];
I_double_bottom=[I_bottom ; 2*I_bottom ; 2*I_bottom+1];
I_double_bottom(I_double_bottom > nb_samples)=nan;
idx_double_bottom=I_double_bottom(~isnan(I_double_bottom))+nb_samples*(J_double_bottom(~isnan(I_double_bottom))-1);
Double_bottom=nan(nb_samples,nb_pings);
Double_bottom(idx_double_bottom)=1;
Double_bottom_region=~isnan(Double_bottom);

%%%%%%%%%%%%%%%%%%%%%Bottom detection and BS analysis%%%%%%%%%%%%%%%%%%%%%%


BS_lin_norm=bsxfun(@rdivide,10.^(BS_ori/20),nansum(10.^(BS_ori/20)));

Bottom_region_bis=Bottom_region;
Bottom_region_bis(isnan(Bottom_region))=0;
BS_lin_norm_bis=BS_lin_norm;
BS_lin_norm_bis(isnan(BS_lin_norm))=0;
BS_lin_cumsum=bsxfun(@rdivide,cumsum(Bottom_region_bis.*BS_lin_norm_bis,1),nansum(Bottom_region.*BS_lin_norm_bis));
[~,Bottom_temp]=nanmin(flipud(abs(BS_lin_cumsum-0.01)));
Bottom_temp=size(BS_lin_cumsum,1)-Bottom_temp;
Bottom_temp_2=nanmin(idx_bottom);
Bottom=nanmax(Bottom_temp_2,Bottom_temp);
backstep=nanmax([1 Np]);

for i=1:nb_pings
    if Bottom(i)>2*backstep
        Bottom(i)=Bottom(i)-backstep;
        
        while nanmax(BS_ori((Bottom(i)-backstep):Bottom(i)-1,i))>=BS_ori(Bottom(i),i) && (Bottom(i))>backstep && nanmax(BS_ori((Bottom(i)-backstep):Bottom(i)-1,i))>=-900
            [~,idx_max_tmp]=nanmax(BS_ori((Bottom(i)-backstep):Bottom(i)-1,i));
            if Bottom(i)-(backstep-idx_max_tmp+1)>0
                Bottom(i)=Bottom(i)-(backstep-idx_max_tmp+1);
            end
            if (Bottom(i))<=backstep
                break;
            end
        end
    end
end

% figure();plot(Bottom_temp)
% hold on;plot(Bottom_temp_2)
% plot(Bottom);

Bottom(Bottom==1)=nan;
Bottom(nanmin(idx_bottom)>=nanmax(1,nb_samples-round(heigh_b_filter)/2))=nan;

BS_filter=(20*log10(filter2_perso(ones(4*Np,1),10.^(BS/20)))).*Bottom_region;

BS_bottom=nanmax(BS_filter);
BS_bottom(isnan(Bottom))=nan;

if p.Results.shift_bot>0
    Bottom=Bottom- ceil(p.Results.shift_bot./nanmean(diff(Range)));
    Bottom(Bottom<=0)=1;
end




% 
% profile off;
% profile viewer;
end


