function [Bottom,Double_bottom_region,BS_bottom,idx_bottom,idx_ringdown]=detec_bottom_algo_v3(trans_obj,varargin)

disp('Detecting Bottom.');
%profile on;
%Parse Arguments
p = inputParser;

default_idx_r_min=0;

default_idx_r_max=Inf;

default_thr_bottom=-35;
check_thr_bottom=@(x)(x>=-120&&x<=-10);

default_thr_backstep=-12;
check_thr_backstep=@(x)(x>=-12&&x<=0);

check_shift_bot=@(x)(x>=0);
check_filt=@(x)(x>0)||isempty(x);

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addParameter(p,'denoised',0,@(x) isnumeric(x)||islogical(x));
addParameter(p,'r_min',default_idx_r_min,@isnumeric);
addParameter(p,'r_max',default_idx_r_max,@isnumeric);
addParameter(p,'thr_bottom',default_thr_bottom,check_thr_bottom);
addParameter(p,'thr_backstep',default_thr_backstep,check_thr_backstep);
addParameter(p,'vert_filt',10,check_filt);
addParameter(p,'horz_filt',50,check_filt);
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
dr=nanmean(diff(Range));
Fs=1/trans_obj.Params.SampleInterval(1);
PulseLength=trans_obj.Params.PulseLength(1);

thr_bottom=p.Results.thr_bottom;
thr_backstep=p.Results.thr_backstep;
r_min=nanmax(p.Results.r_min,2);
r_max=p.Results.r_max;

thr_echo=-12;

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


%First let's find the bottom...

dist=trans_obj.GPSDataPing.Dist;
heigh_b_filter=floor(p.Results.vert_filt/dr)+1;

if ~isempty(dist)&&nb_pings>1
    b_filter=floor(p.Results.horz_filt/nanmax(diff(dist)))+1;
else
    b_filter=nanmin(15,nb_pings/10);
end

idx_ringdown=analyse_ringdown(RingDown);

BS=bsxfun(@plus,Sv,10*log10(Range));

BS(isnan(BS))=-999;
BS_mask_ori=((filter2(ones(3,3),BS>=-999,'same'))<=2);
BS(BS_mask_ori)=-999;
BS_ori=BS;


BS(:,~idx_ringdown)=nan;
BS_lin=10.^(BS/10);
BS_lin(isnan(BS_lin))=0;

  
filter_fun = @(block_struct) nanmean(block_struct.data(:));
BS_filtered_bot_lin=blockproc(BS_lin,[heigh_b_filter b_filter],filter_fun);
[nb_samples_red,~]=size(BS_filtered_bot_lin);
BS_filtered_bot_lin(1:floor(idx_r_min/nb_samples*nb_samples_red),:)=nan;
BS_filtered_bot_lin(ceil(idx_r_max/nb_samples*nb_samples_red):end,:)=nan;
BS_filtered_bot=10*log10(BS_filtered_bot_lin);
BS_filtered_bot_lin(isnan(BS_filtered_bot_lin))=0;


cumsum_BS=cumsum((BS_filtered_bot_lin));
cumsum_BS(cumsum_BS<0)=nan;
diff_cum_BS=diff(10*log10(cumsum_BS));
diff_cum_BS(1:nanmin(floor(idx_r_min/heigh_b_filter)+1,nb_samples_red),:)=0;
diff_cum_BS(isnan(diff_cum_BS))=0;

[~,idx_max_diff_cum_BS]=nanmax(diff_cum_BS);

idx_start=nanmax(idx_max_diff_cum_BS,idx_r_min/heigh_b_filter);
idx_end=nanmin(idx_max_diff_cum_BS+3,idx_r_max/heigh_b_filter);

Bottom_region=bsxfun(@ge,(1:nb_samples_red)',idx_start)&bsxfun(@le,(1:nb_samples_red)',idx_end);

Max_BS_reg=bsxfun(@gt,BS_filtered_bot,nanmax(BS_filtered_bot)+thr_echo);
Bottom_region=find_cluster((Bottom_region&BS_filtered_bot>=thr_bottom&Max_BS_reg),1);

Bottom_region=ceil(filter2_perso(ones(1,3),Bottom_region));

Bottom_region=imresize(Bottom_region,[nb_samples nb_pings],'nearest');


n_permut=nanmin(floor((heigh_b_filter+1)/4),nb_samples);
Permut=[nb_samples-n_permut+1:nb_samples 1:nb_samples-n_permut];

Bottom_region=Bottom_region(Permut,:);
Bottom_region(1:n_permut,:)=0;

Bottom_region(:,nansum(Bottom_region)<=Np)=0;


idx_bottom=bsxfun(@times,Bottom_region,(1:nb_samples)');
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


BS_lin_norm=bsxfun(@rdivide,BS_lin,nansum(BS_lin));

Bottom_region_bis=Bottom_region;
Bottom_region_bis(isnan(Bottom_region))=0;
BS_lin_norm_bis=BS_lin_norm;
BS_lin_norm_bis(isnan(BS_lin_norm))=0;
BS_lin_cumsum=(cumsum(Bottom_region_bis.*BS_lin_norm_bis,1)./repmat(nansum(Bottom_region.*BS_lin_norm_bis),size(Bottom_region,1),1));
[~,Bottom_temp]=nanmin((abs(BS_lin_cumsum-0.01)));
 
Bottom_temp_2=nanmin(idx_bottom);
Bottom=nanmax(Bottom_temp,Bottom_temp_2);

backstep=nanmax([1 Np]);

for i=1:nb_pings
    if Bottom(i)>2*backstep
        Bottom(i)=Bottom(i)-backstep;
        
        while nanmax(BS_ori((Bottom(i)-backstep):Bottom(i)-1,i))>=BS_ori(Bottom(i),i)+thr_backstep &&...
            Bottom(i)>backstep &&...
            nanmax(BS_ori((Bottom(i)-backstep):Bottom(i)-1,i))>=-999
            [~,idx_max_tmp]=nanmax(BS_ori((Bottom(i)-backstep):Bottom(i)-1,i));
            if Bottom(i)-(backstep-idx_max_tmp+1)>0
                Bottom(i)=Bottom(i)-(backstep-idx_max_tmp+1);
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


