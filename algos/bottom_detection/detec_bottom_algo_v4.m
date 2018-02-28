%% detec_bottom_algo_v4.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% TODO
%
% *OUTPUT VARIABLES*
%
% TODO
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-04-02: header (Alex Schimel).
% * YYYY-MM-DD: first version (Yoann Ladroit). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function [Bottom,Double_bottom_region,BS_bottom,idx_bottom,idx_ringdown]=detec_bottom_algo_v4(trans_obj,varargin)

%profile on;
%Parse Arguments

p = inputParser;

default_idx_r_min=0;

default_idx_r_max=Inf;

default_thr_bottom=-35;
check_thr_bottom=@(x)(x>=-120&&x<=-3);

default_thr_backstep=-1;
check_thr_backstep=@(x)(x>=-12&&x<=12);

check_shift_bot=@(x) isnumeric(x);

check_thr_cum=@(x)(x>=0&&x<=100);


addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addParameter(p,'denoised',0,@(x) isnumeric(x)||islogical(x));
addParameter(p,'r_min',default_idx_r_min,@isnumeric);
addParameter(p,'r_max',default_idx_r_max,@isnumeric);
addParameter(p,'reg_obj',region_cl.empty(),@(x) isa(x,'region_cl'));
addParameter(p,'thr_bottom',default_thr_bottom,check_thr_bottom);
addParameter(p,'thr_backstep',default_thr_backstep,check_thr_backstep);
addParameter(p,'thr_echo',-35,check_thr_bottom);
addParameter(p,'thr_cum',1,check_thr_cum);
addParameter(p,'shift_bot',0,check_shift_bot);
addParameter(p,'rm_rd',0);
addParameter(p,'load_bar_comp',[]);
parse(p,trans_obj,varargin{:});


if isempty(p.Results.reg_obj)
    idx_r=1:length(trans_obj.get_transceiver_range());
    idx_pings=1:length(trans_obj.get_transceiver_pings());
    %mask=zeros(numel(idx_r),numel(idx_pings));
    %reg_obj=region_cl('Idx_r',idx_r,'Idx_pings',idx_pings);
else
    idx_pings=p.Results.reg_obj.Idx_pings;
    idx_r=p.Results.reg_obj.Idx_r;
    %mask=~(p.Results.reg_obj.create_mask());
    %reg_obj=p.Results.reg_obj; 
end

if p.Results.denoised>0
    Sp=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','spdenoised');
    if isempty(Sp)
        Sp=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','sp');
    end
else
    Sp=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','sp');
end

%Sp(mask>0)=-999;

Range= trans_obj.get_transceiver_range(idx_r);
[~,Np]=trans_obj.get_pulse_length(1);

thr_bottom=p.Results.thr_bottom;
thr_backstep=p.Results.thr_backstep;
r_min=nanmax(p.Results.r_min,2);
r_max=p.Results.r_max;

thr_echo=p.Results.thr_echo;
thr_cum=p.Results.thr_cum/100;

[nb_samples,nb_pings]=size(Sp);

load_bar_comp=p.Results.load_bar_comp;
if ~isempty(p.Results.load_bar_comp)
    set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',nb_pings, 'Value',0);
end

if r_max==Inf
    idx_r_max=nb_samples;
else
    [~,idx_r_max]=nanmin(abs(r_max-Range));
    idx_r_max=nanmin(idx_r_max,nb_samples);
    idx_r_max=nanmax(idx_r_max,10);
end

[~,idx_r_min]=nanmin(abs(r_min-Range));
idx_r_min=nanmax(idx_r_min,5*Np);
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

BS(isnan(BS))=-999;
BS_ori=BS;

BS(:,~idx_ringdown)=nan;

BS_lin=10.^(BS/10);
[max_bs,~]=nanmax(BS);
Max_BS_reg=(bsxfun(@gt,BS,max_bs+thr_echo));
Max_BS_reg(:,max_bs<thr_bottom)=0;

Bottom_region_temp=Max_BS_reg;

Bottom_region_temp=ceil(filter2(ones(2*Np,5),Bottom_region_temp))>=(2*5*Np/2);

idx_empty=nansum(Bottom_region_temp)==0;
Bottom_region_temp(:,idx_empty)=[];


Bottom_region=zeros(size(BS));
Bottom_region(:,~idx_empty)=Bottom_region_temp;


idx_bottom=bsxfun(@times,Bottom_region,(1:nb_samples)');
idx_bottom(~Bottom_region)=nan;
idx_bottom(end,(nansum(idx_bottom)==0))=nb_samples;
bottom_temp=nanmin(idx_bottom);

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

BS_lin_norm=bsxfun(@rdivide,Bottom_region.*BS_lin.^2,nansum(Bottom_region.*BS_lin.^2));

BS_lin_norm_bis=BS_lin_norm;
BS_lin_norm_bis(isnan(BS_lin_norm))=0;
BS_lin_cumsum=(cumsum(BS_lin_norm_bis,1)./repmat(sum(BS_lin_norm_bis),size(Bottom_region,1),1));
BS_lin_cumsum(BS_lin_cumsum<thr_cum)=Inf;
[~,Bottom]=min((abs(BS_lin_cumsum-thr_cum)));

Bottom=nanmax(bottom_temp,Bottom);

backstep=nanmax([1 Np]);

for i=1:nb_pings
    
    if mod(i,floor(nb_pings/100))==1  
        if ~isempty(load_bar_comp)
            set(load_bar_comp.progress_bar,'Value',i);
        end
    end
    BS_ping=BS_ori(:,i);
    if Bottom(i)>2*backstep
        
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
    
    Bottom(i)=nanmax(Bottom(i)-backstep,1);
end


Bottom(Bottom==1)=nan;
Bottom(idx_empty)=nan;

BS_filter=(20*log10(filter(ones(4*Np,1)/(4*Np),1,10.^(BS/20)))).*Bottom_region;
BS_filter(Bottom_region==0)=nan;

BS_bottom=nanmax(BS_filter);
BS_bottom(isnan(Bottom))=nan;

idx_low=(BS_bottom<thr_bottom);

Bottom=Bottom- ceil(p.Results.shift_bot./nanmax(diff(Range)));
Bottom(idx_low)=nan;
BS_bottom(idx_low)=nan;
Bottom(Bottom<=0)=1;

bottom_ori=trans_obj.get_bottom_idx();
bottom_ori(idx_pings)=Bottom+idx_r(1)-1;
Bottom=bottom_ori;

% profile off;
% profile viewer;

end


