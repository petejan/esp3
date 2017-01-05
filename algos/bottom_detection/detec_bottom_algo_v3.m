function [Bottom,Double_bottom_region,BS_bottom,idx_bottom,idx_ringdown]=detec_bottom_algo_v3(trans_obj,varargin)

%profile on;
%Parse Arguments
t0=tic;
p = inputParser;

default_idx_r_min=0;

default_idx_r_max=Inf;

default_thr_bottom=-35;
check_thr_bottom=@(x)(x>=-120&&x<=-3);

default_thr_backstep=-1;
check_thr_backstep=@(x)(x>=-12&&x<=12);

check_shift_bot=@(x) isnumeric(x);
check_filt=@(x)(x>=0)||isempty(x);

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addParameter(p,'denoised',0,@(x) isnumeric(x)||islogical(x));
addParameter(p,'r_min',default_idx_r_min,@isnumeric);
addParameter(p,'r_max',default_idx_r_max,@isnumeric);
addParameter(p,'idx_r',[],@isnumeric);
addParameter(p,'idx_pings',[],@isnumeric);
addParameter(p,'thr_bottom',default_thr_bottom,check_thr_bottom);
addParameter(p,'thr_backstep',default_thr_backstep,check_thr_backstep);
addParameter(p,'vert_filt',10,check_filt);
addParameter(p,'horz_filt',50,check_filt);
addParameter(p,'shift_bot',0,check_shift_bot);
addParameter(p,'rm_rd',0);
addParameter(p,'load_bar_comp',[]);
parse(p,trans_obj,varargin{:});

if isempty(p.Results.idx_r)
    idx_r=1:length(trans_obj.Data.get_range());
else
    idx_r=p.Results.idx_r;
end

if isempty(p.Results.idx_pings)
    idx_pings=1:length(trans_obj.Data.get_numbers());
else
    idx_pings=p.Results.idx_pings;
end

if p.Results.denoised>0
    Sp=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','spdenoised');
    if isempty(Sp)
        Sp=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','sp');
    end
else
    Sp=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','sp');
end

Range= trans_obj.Data.get_range(idx_r);
dr=nanmean(diff(Range));
Fs=1/trans_obj.Params.SampleInterval(1);
PulseLength=trans_obj.Params.PulseLength(1);

thr_bottom=p.Results.thr_bottom;
thr_backstep=p.Results.thr_backstep;
r_min=nanmax(p.Results.r_min,2);
r_max=p.Results.r_max;

thr_echo=-35;
thr_cum=0.01;

[nb_samples,nb_pings]=size(Sp);

load_bar_comp=p.Results.load_bar_comp;
if ~isempty(p.Results.load_bar_comp)
    set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',nb_pings, 'Value',0);
end


Np=round(PulseLength*Fs);
if r_max==Inf
    idx_r_max=nb_samples;
else
    [~,idx_r_max]=nanmin(abs(r_max+p.Results.vert_filt-Range));
    idx_r_max=nanmin(idx_r_max,nb_samples);
    idx_r_max=nanmax(idx_r_max,10);
end

[~,idx_r_min]=nanmin(abs(r_min-p.Results.vert_filt-Range));
idx_r_min=nanmax(idx_r_min,10);
idx_r_min=nanmin(idx_r_min,nb_samples);

RingDown=Sp(3,:);
Sp(1:idx_r_min,:)=nan;
Sp(idx_r_max:end,:)=nan;

%First let's find the bottom...

dist=trans_obj.GPSDataPing.Dist;
heigh_b_filter=floor(p.Results.vert_filt/dr)+1;

if ~isempty(dist)&&nb_pings>1&&p.Results.horz_filt>0
    b_filter=floor(p.Results.horz_filt/nanmax(diff(dist)))+1;
else
    b_filter=ceil(nanmin(15,nb_pings/10));
    %b_filter=nb_pings;
end
if p.Results.rm_rd
    idx_ringdown=analyse_ringdown(RingDown);
else
    idx_ringdown=ones(size(RingDown));
end

BS=bsxfun(@minus,Sp,10*log10(Range));

BS(isnan(BS))=-999;
BS_ori=BS;


BS(:,~idx_ringdown)=nan;
BS_lin=10.^(BS/10);
BS_lin(isnan(BS_lin))=0;

BS_lin_red=BS_lin(idx_r_min:idx_r_max,:);

  
filter_fun = @(block_struct) max(block_struct.data(:));
BS_filtered_bot_lin=blockproc(BS_lin_red,[heigh_b_filter b_filter],filter_fun);
[nb_samples_red,~]=size(BS_filtered_bot_lin);

BS_filtered_bot=10*log10(BS_filtered_bot_lin);
BS_filtered_bot_lin(isnan(BS_filtered_bot_lin))=0;

cumsum_BS=cumsum((BS_filtered_bot_lin));
cumsum_BS(cumsum_BS<0)=nan;
diff_cum_BS=diff(10*log10(cumsum_BS));
diff_cum_BS(isnan(diff_cum_BS))=0;

[~,idx_max_diff_cum_BS]=nanmax(diff_cum_BS);

idx_start=idx_max_diff_cum_BS-1;
idx_end=idx_max_diff_cum_BS+3;

Bottom_region=(bsxfun(@ge,(1:nb_samples_red)',idx_start)&bsxfun(@le,(1:nb_samples_red)',idx_end));
max_bs=nanmax(BS_filtered_bot);
Max_BS_reg=(bsxfun(@gt,BS_filtered_bot,max_bs+thr_echo));
Max_BS_reg(:,max_bs<thr_bottom)=0;

Bottom_region=find_cluster((Bottom_region>0&BS_filtered_bot>=thr_bottom&Max_BS_reg),1);

Bottom_region=ceil(filter(ones(1,3)/3,1,Bottom_region));
Bottom_region_red=imresize(Bottom_region,size(BS_lin_red),'nearest');
Bottom_region=zeros(size(BS_lin));
Bottom_region(idx_r_min:idx_r_max,:)=Bottom_region_red;

n_permut=nanmin(floor((heigh_b_filter+1)/4),nb_samples);
Permut=[nb_samples-n_permut+1:nb_samples 1:nb_samples-n_permut];

Bottom_region=Bottom_region(Permut,:);
Bottom_region(1:n_permut,:)=0;

idx_bottom=bsxfun(@times,Bottom_region,(1:nb_samples)');
idx_bottom(~Bottom_region)=nan;
idx_bottom(end,(nansum(idx_bottom)==0))=nb_samples;


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


BS_lin_norm=bsxfun(@rdivide,Bottom_region.*BS_lin,nansum(Bottom_region.*BS_lin));


BS_lin_norm_bis=BS_lin_norm;
BS_lin_norm_bis(isnan(BS_lin_norm))=0;
BS_lin_cumsum=(cumsum(BS_lin_norm_bis,1)./repmat(sum(BS_lin_norm_bis),size(Bottom_region,1),1));
BS_lin_cumsum(BS_lin_cumsum<thr_cum)=Inf;
[~,Bottom_temp]=min((abs(BS_lin_cumsum-thr_cum)));
Bottom_temp_2=nanmin(idx_bottom);
Bottom=nanmax(Bottom_temp,Bottom_temp_2);

backstep=nanmax([1 Np]);

for i=1:nb_pings
    if mod(i,floor(nb_pings/100))==1  
        if ~isempty(load_bar_comp)
            set(load_bar_comp.progress_bar,'Value',i);
        end
    end
    BS_ping=BS_ori(:,i);
    if Bottom(i)>2*backstep
        Bottom(i)=Bottom(i)-backstep;
        if Bottom(i)>backstep
            [bs_val,idx_max_tmp]=nanmax(BS_ping((Bottom(i)-backstep):Bottom(i)-1));
        else
            continue;
        end

        while bs_val>=BS_ping(Bottom(i))+thr_backstep &&bs_val>-999
            if Bottom(i)-(backstep-idx_max_tmp+1)>0
                Bottom(i)=Bottom(i)-(backstep-idx_max_tmp+1);
            end
            if Bottom(i)>backstep
                [bs_val,idx_max_tmp]=nanmax(BS_ping((Bottom(i)-backstep):Bottom(i)-1));
            else
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

BS_filter=(20*log10(filter(ones(4*Np,1)/(4*Np),1,10.^(BS/20)))).*Bottom_region;
BS_filter(Bottom_region==0)=nan;

BS_bottom=nanmax(BS_filter);
BS_bottom(isnan(Bottom))=nan;

if p.Results.shift_bot>0
    Bottom=Bottom- ceil(p.Results.shift_bot./nanmean(diff(Range)));
    Bottom(Bottom<=0)=1;
end

t1=toc(t0);
fprintf('Bottom detected in %0.2fs\n',t1);

bottom_ori=trans_obj.get_bottom_idx();
bottom_ori(idx_pings)=Bottom+idx_r(1)-1;
Bottom=bottom_ori;
% profile off;
% profile viewer;

end


