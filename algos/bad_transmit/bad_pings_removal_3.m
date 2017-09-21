%% bad_pings_removal_3.m
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
% * |trans_obj|: TODO: write description and info on variable
% * |denoised|: TODO description (Optional. Num or logical. Default: 0).
% * |BS_std|: TODO description (Optional).
% * |BS_std_bool|: TODO description (Optional. Num or logical. Default:|true|).
% * |thr_spikes_Above|: TODO description (Optional).
% * |thr_spikes_Below|: TODO description (Optional).
% * |Above|: TODO description (Optional. Num or logical. Default:|true|).
% * |Below|: TODO description (Optional. Num or logical. Default:|true|).
% * |load_bar_comp|: TODO description (Optional. Default: empty);
%
% *OUTPUT VARIABLES*
%
% * |Bottom|: TODO: write description and info on variable
% * |Double_bottom_region|: TODO: write description and info on variable
% * |idx_noise_sector|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
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
function idx_noise_sector = bad_pings_removal_3(trans_obj,varargin)
global DEBUG

%% managing input variables

p = inputParser;

% default values for input parameters
default_BS_std       = 9;
default_spikes       = 3;

% functions for valid values
check_BS_std       = @(x)(x>=0)&&(x<=20);
check_spikes       = @(x)(x>=0&&x<=20);


% fill in the parser
addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addParameter(p,'denoised',0,@(x) isnumeric(x)||islogical(x));
addParameter(p,'BS_std',default_BS_std,check_BS_std);
addParameter(p,'BS_std_bool',true,@(x) islogical(x)||isnumeric(x));
addParameter(p,'thr_spikes_Above',default_spikes,check_spikes);
addParameter(p,'thr_spikes_Below',default_spikes,check_spikes);
addParameter(p,'Above',true,@(x) isnumeric(x)||islogical(x));
addParameter(p,'Below',true,@(x) isnumeric(x)||islogical(x));
addParameter(p,'reg_obj',region_cl.empty(),@(x) isa(x,'region_cl'));
addParameter(p,'load_bar_comp',[]);

% parse
parse(p,trans_obj,varargin{:});



% grab values from the parser
BS_std           = p.Results.BS_std;
BS_std_bool      = p.Results.BS_std_bool;
thr_spikes_Above = p.Results.thr_spikes_Above;
thr_spikes_Below = p.Results.thr_spikes_Below;
Above            = p.Results.Above;
Below            = p.Results.Below;


if ~isempty(p.Results.reg_obj)
    idx_r=1:length(trans_obj.get_transceiver_range());
    idx_pings=1:length(trans_obj.get_transceiver_pings());
    mask=zeros(numel(idx_r),numel(idx_pings));
    %reg_obj=region_cl('Idx_r',idx_r,'Idx_pings',idx_pings);
else
    idx_pings=p.Results.reg_obj.Idx_pings;
    idx_r=p.Results.reg_obj.Idx_r;
    mask=~(p.Results.reg_obj.create_mask());
    %reg_obj=p.Results.reg_obj; 
end

%% more pre-processing

% grab data to work on
if p.Results.denoised>0
    Sv = trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','svdenoised');
    if isempty(Sv)
        Sv = trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','sv');
    end
else
    Sv = trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','sv');
end
Sv(mask>0)=-999;

[nb_samples,nb_pings] = size(Sv);

if idx_r(1)<=20
    start_sample = nanmin([20-idx_r(1)+1 nb_samples]);
    Sv(1:start_sample,:) = nan; % we nan the first 20 samples
else
    start_sample=1;
end
% grab extra parameters
%Fs          = 1/trans_obj.Params.SampleInterval(1); % sampling frequency
%PulseLength = trans_obj.Params.PulseLength(1); % pulse duration
%Np          = round(PulseLength*Fs); % number of samples in pulse


RingDown = trans_obj.Data.get_subdatamat(3,idx_pings,'field','sv');

idx_ringdown=analyse_ringdown(RingDown);

% define b_filter:
b_filter = 3:2:7;

%% First let's get the bottom and the BS...
Range= trans_obj.get_transceiver_range(idx_r);
BS=bsxfun(@plus,Sv,10*log10(Range));
idx_bottom=trans_obj.get_bottom_idx(idx_pings);
idx_bs=bsxfun(@(x,y) x>=y<=(y*11/10),trans_obj.get_transceiver_samples(),idx_bottom);
BS(~idx_bs)=nan;
BS_bottom=lin_space_mean(BS);

%% BS Analysis
if BS_std_bool>0
    
    % Bottom is the sample corresponding to the bottom detect
    % BS_bottom is the backscatter level of the sample corresponding to the bottom detection
    BS_bottom(idx_bottom<start_sample) = nan;
    
    BS_bottom_analysis = BS_bottom;
    BS_bottom_analysis(isnan(idx_bottom)|idx_bottom==nb_samples) = nan;
    
    % BS_std_up = -20*log10((sqrt(4/pi-1)));
    % BS_std_dw = 20*log10((sqrt(4/pi-1)));
    
    BS_std_up =  BS_std;
    BS_std_dw = -BS_std;
    
    Mean_BS = nan(length(b_filter),nb_pings);
    
    for j = 1:length(b_filter)
        
        filter_window = ones(1,b_filter(j));
        Mean_BS(j,:) = 20*log10( filter_nan(filter_window,10.^(BS_bottom_analysis/20)) ./ filter_nan(filter_window,ones(1,length(BS_bottom))) );
        
        idx_temp = ((BS_bottom_analysis-Mean_BS(j,:)) <= BS_std_up & (BS_bottom_analysis-Mean_BS(j,:)) >= BS_std_dw);
        
        BS_bottom_analysis(~idx_temp) = nan;
        
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
    
    idx_bottom_bs_eval = ~isnan(BS_bottom_analysis);
    idx_bottom_bs_eval(nansum(idx_bottom)==0) = 1;
    idx_bottom_bs_eval(isnan(idx_bottom)) = 1;
    idx_bottom_bs_eval(isnan(BS_bottom)) = 1;
    
else
    idx_bottom_bs_eval = ones(1,nb_pings);
end

if isempty(p.Results.idx_r)
    idx_below=bsxfun(@(x,y) x>y*12/10&x<y*14/10,idx_r(:),idx_bottom);
    idx_above=bsxfun(@(x,y) x<y*9.5/10&x>y/2,idx_r(:),idx_bottom);
else
    idx_below=bsxfun(@(x,y) x>y*11/10,idx_r(:),idx_bottom);
    idx_above=bsxfun(@(x,y) x<y,idx_r(:),idx_bottom);
end




%% Removing noisy pings
idx_bad_above=[];
idx_bad_below=[];
if Above>0
    thr_down=-thr_spikes_Above*[1 2 2 2];
    thr_up=-thr_spikes_Above*[1 2 2];
    Sv_Above=nan(size(Sv));
    Sv_Above(idx_above)=Sv(idx_above);    
    sv_mean_vert_above=lin_space_mean(Sv_Above);
    
    [idx_bad_up,idx_bad_down]=find_idx_bad_up_down(sv_mean_vert_above,thr_down,thr_up);
    
    idx_bad_above=union(idx_bad_up,idx_bad_down);
else
    sv_mean_vert_above=nan(1,nb_pings);
end


if Below>0
    %thr_down=-thr_spikes_Below*[1 2 2 2] ;
    thr_up=-thr_spikes_Below*[1 2 2];
    Sv_Below=nan(size(Sv));
    Sv_Below(idx_below)=Sv(idx_below);
    sv_mean_vert_below=lin_space_mean(Sv_Below);
    [idx_bad_below,~]=find_idx_bad_up_down(sv_mean_vert_below,[],thr_up);   
else
    sv_mean_vert_below=nan(1,nb_pings);
end


if DEBUG==1
    sv_mean_vert_bad_below=nan(1,nb_pings);
    sv_mean_vert_bad_above=nan(1,nb_pings);
    sv_mean_vert_bad_below(idx_bad_below)=sv_mean_vert_below(idx_bad_below);
    sv_mean_vert_bad_above(idx_bad_above)=sv_mean_vert_above(idx_bad_above);
    
    
    h_fig=new_echo_figure([],'Name','Bad Transmits test','Tag','temp_badt');
    ax=axes(h_fig,'nextplot','add');
    grid(ax,'on');
    plot(ax,sv_mean_vert_below,'-+');
    plot(ax,sv_mean_vert_bad_below,'or');
    
    plot(ax,sv_mean_vert_above,'-x');
    plot(ax,sv_mean_vert_bad_above,'ok');
end

%%%%%%And compile the final vector designing the bad pings%%%%%%%%%%%%%%%%
idx_bs=find(~idx_bottom_bs_eval);
idx_rd=find(~idx_ringdown);

idx_noise_sector=unique([idx_bad_below(:)' idx_bad_above(:)' idx_bs(:)' idx_rd(:)']);
idx_noise_sector=idx_noise_sector+idx_pings(1)-1;

%%%%%%%%%%%%%Remove isolated "good" pings%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% idx_noise_sector_filter = filter(ones(1,9),1,idx_noise_sector/9);
% idx_noise_sector(idx_noise_sector_filter>=7/9) = 1;

bad_pings_percent = numel(idx_noise_sector)/nb_pings*100;
disp([num2str(bad_pings_percent) '% of bad pings']);


end

function [idx_bad_up,idx_bad_down]=find_idx_bad_up_down(sv_mean_vert,thr_down,thr_up)
idx_bad_down=[];
idx_bad_up=[];
for i=1:numel(thr_down)
    idx_bad_tmp=find_idx_bad(sv_mean_vert,i,thr_down(i));
    idx_bad_down=union(idx_bad_tmp,idx_bad_down);
end
sv_mean_vert(idx_bad_down)=nan;

for i=1:numel(thr_up)
    idx_bad_tmp=find_idx_bad(-sv_mean_vert,i,thr_up(i));
    idx_bad_up=union(idx_bad_tmp,idx_bad_up);
end
end


function idx_bad=find_idx_bad(sv_mean_vert,order,thr_down)

diff_sv=sv_mean_vert(1+order:end)-sv_mean_vert(1:end-order);

diff_sv_rl=[nan(1,order) diff_sv];
diff_sv_lr=[-diff_sv nan(1,order)];

idx_bad=find((diff_sv_rl<=thr_down&diff_sv_lr<=thr_down)|...
    (diff_sv_rl<=thr_down&diff_sv_lr>=-thr_down)|...
    (diff_sv_rl>=-thr_down&diff_sv_lr<=thr_down));

end
