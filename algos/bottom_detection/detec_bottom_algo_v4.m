function [Bottom,Double_bottom_region,BS_bottom,idx_bottom,idx_ringdown]=detec_bottom_algo_v4(trans_obj,varargin)

%profile on;
%Parse Arguments
t0=tic;
p = inputParser;

default_idx_r_min=0;

default_idx_r_max=Inf;

default_thr_bottom=-35;
check_thr_bottom=@(x)(x>=-120&&x<=-10);

default_thr_backstep=-1;
check_thr_backstep=@(x)(x>=-12&&x<=0);

check_shift_bot=@(x)(x>=0);
check_filt=@(x)(x>=0)||isempty(x);

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addParameter(p,'denoised',0,@(x) isnumeric(x)||islogical(x));
addParameter(p,'r_min',default_idx_r_min,@isnumeric);
addParameter(p,'r_max',default_idx_r_max,@isnumeric);
addParameter(p,'thr_bottom',default_thr_bottom,check_thr_bottom);
addParameter(p,'thr_backstep',default_thr_backstep,check_thr_backstep);
addParameter(p,'vert_filt',10,check_filt);
addParameter(p,'horz_filt',50,check_filt);
addParameter(p,'shift_bot',0,check_shift_bot);
addParameter(p,'rm_rd',0);
parse(p,trans_obj,varargin{:});

if p.Results.denoised>0
    Sp=trans_obj.Data.get_datamat('spdenoised');
    if isempty(Sp)
        Sp=trans_obj.Data.get_datamat('sp');
    end
else
    Sp=trans_obj.Data.get_datamat('sp');
end

eq_beam_angle=trans_obj.Config.EquivalentBeamAngle;
Range= trans_obj.Data.get_range();
Fs=1/trans_obj.Params.SampleInterval(1);
PulseLength=trans_obj.Params.PulseLength(1);

thr_bottom=p.Results.thr_bottom;
thr_backstep=p.Results.thr_backstep;
r_min=nanmax(p.Results.r_min,2);
r_max=p.Results.r_max;

thr_echo=-35;
thr_cum=0.01;

[nb_samples,nb_pings]=size(Sp);

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


if p.Results.rm_rd
    idx_ringdown=analyse_ringdown(RingDown);
else
    idx_ringdown=ones(size(RingDown));
end

BS=bsxfun(@minus,Sp,10*log10(Range));
BS=Sp;
BS(isnan(BS))=-999;
BS_ori=BS;

BS(:,~idx_ringdown)=nan;
BS_lin=10.^(BS/10);
max_bs=nanmax(BS);
Max_BS_reg=(bsxfun(@gt,BS,max_bs+thr_echo));
Max_BS_reg(:,max_bs<thr_bottom)=0;

Bottom_region=BS>thr_bottom&Max_BS_reg;
Bottom_region=floor(filter2(ones(2*Np,1),Bottom_region)/(2*Np))==1;
Bottom_region=ceil(filter2(ones(2*Np,2),Bottom_region)/(4*Np))==1;

%figure();imagesc(Bottom_region)

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
[~,Bottom]=min((abs(BS_lin_cumsum-thr_cum)));

backstep=nanmax([1 Np]);

for i=1:nb_pings
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


Bottom(Bottom==1)=nan;

BS_filter=(20*log10(filter2_perso(ones(4*Np,1),10.^(BS/20)))).*Bottom_region;
BS_filter(Bottom_region==0)=nan;

BS_bottom=nanmax(BS_filter);
BS_bottom(isnan(Bottom))=nan;

if p.Results.shift_bot>0
    Bottom=Bottom- ceil(p.Results.shift_bot./nanmean(diff(Range)));
    Bottom(Bottom<=0)=1;
end

t1=toc(t0);
fprintf('Bottom detected in %0.2fs\n',t1);
% profile off;
% profile viewer;

end


