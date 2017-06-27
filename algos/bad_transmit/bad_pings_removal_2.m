%% bad_pings_removal_2.m
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
% * |thr_bottom|: TODO description (Optional. TODO)
% * |thr_echo|: TODO description (Optional. Default: -40. TODO).
% * |thr_cum|: TODO description (Optional. Default: 0.01. TODO).
% * |thr_backstep|: TODO description (Optional. TODO).
% * |vert_filt|: TODO description (Optional. Default: 10. TODO).
% * |horz_filt|: TODO description (Optional. Default: 50. TODO).
% * |r_min|: TODO description (Optional. Num).
% * |r_max|: TODO description (Optional. Num).
% * |BS_std|: TODO description (Optional).
% * |BS_std_bool|: TODO description (Optional. Num or logical. Default:|true|).
% * |thr_spikes_Above|: TODO description (Optional).
% * |thr_spikes_Below|: TODO description (Optional).
% * |Above|: TODO description (Optional. Num or logical. Default:|true|).
% * |Below|: TODO description (Optional. Num or logical. Default:|true|).
% * |shift_bot|: TODO description (Optional. Default: 0).
% * |botDetecVer|: TODO description (Optional. Default: 'V2').
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
function [Bottom,Double_bottom_region,idx_noise_sector] = bad_pings_removal_2(trans_obj,varargin)
global DEBUG

%% managing input variables

p = inputParser;

% default values for input parameters
default_BS_std       = 6;
default_thr_bottom   = -35;
default_thr_backstep = -12;
default_idx_r_min    = 0;
default_idx_r_max    = Inf;
default_spikes       = 4;

% functions for valid values
check_BS_std       = @(x)(x>=3)&&(x<=20);
check_thr_bottom   = @(x)(x>=-120&&x<=-3);
check_thr_backstep = @(x)(x>=-12&&x<=12);
check_spikes       = @(x)(x>=0&&x<=20);
check_filt         = @(x)(x>=0);
check_shift_bot    = @isnumeric;

% fill in the parser
addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addParameter(p,'denoised',0,@(x) isnumeric(x)||islogical(x));
addParameter(p,'thr_bottom',default_thr_bottom,check_thr_bottom);
addParameter(p,'thr_echo',-40,check_thr_bottom);
addParameter(p,'thr_cum',1,check_filt);
addParameter(p,'thr_backstep',default_thr_backstep,check_thr_backstep);
addParameter(p,'vert_filt',10,check_filt);
addParameter(p,'horz_filt',50,check_filt);
addParameter(p,'r_min',default_idx_r_min,@isnumeric);
addParameter(p,'r_max',default_idx_r_max,@isnumeric);
addParameter(p,'BS_std',default_BS_std,check_BS_std);
addParameter(p,'BS_std_bool',true,@(x) islogical(x)||isnumeric(x));
addParameter(p,'thr_spikes_Above',default_spikes,check_spikes);
addParameter(p,'thr_spikes_Below',default_spikes,check_spikes);
addParameter(p,'Above',true,@(x) isnumeric(x)||islogical(x));
addParameter(p,'Below',true,@(x) isnumeric(x)||islogical(x));
addParameter(p,'shift_bot',0,check_shift_bot);
addParameter(p,'botDetecVer','V2',@ischar);
addParameter(p,'load_bar_comp',[]);

% parse
parse(p,trans_obj,varargin{:});

% grab values from the parser
thr_bottom       = p.Results.thr_bottom;
thr_backstep     = p.Results.thr_backstep;
r_min            = p.Results.r_min;
r_max            = p.Results.r_max;
BS_std           = p.Results.BS_std;
BS_std_bool      = p.Results.BS_std_bool;
thr_spikes_Above = p.Results.thr_spikes_Above;
thr_spikes_Below = p.Results.thr_spikes_Below;
Above            = p.Results.Above;
Below            = p.Results.Below;
shift_bot        = p.Results.shift_bot;

%% more pre-processing

% grab data to work on
if p.Results.denoised>0
    Sv = trans_obj.Data.get_datamat('svdenoised');
    if isempty(Sv)
        Sv = trans_obj.Data.get_datamat('sv');
    end
else
    Sv = trans_obj.Data.get_datamat('sv');
end
[nb_samples,nb_pings] = size(Sv);
start_sample = nanmin([50 nb_samples]);
Sv(1:start_sample,:) = nan; % we nan the first 50 samples

% grab extra parameters
Fs          = 1/trans_obj.Params.SampleInterval(1); % sampling frequency
PulseLength = trans_obj.Params.PulseLength(1); % pulse duration
Np          = round(PulseLength*Fs); % number of samples in pulse

% define b_filter:
b_filter = 3:2:7;

%% First let's find the bottom...
switch p.Results.botDetecVer
    case 'V1'
        [Bottom,Double_bottom_region,BS_bottom,idx_bottom,idx_ringdown]=detec_bottom_algo_v3(trans_obj,...
            'denoised',p.Results.denoised,...
            'thr_bottom',thr_bottom,...
            'thr_backstep',thr_backstep,...
            'horz_filt',p.Results.horz_filt,...
            'vert_filt',p.Results.vert_filt,...
            'r_min',r_min,...
            'r_max',r_max,...
            'shift_bot',shift_bot,...
            'rm_rd',1,...
            'load_bar_comp',p.Results.load_bar_comp);
    otherwise
        [Bottom,Double_bottom_region,BS_bottom,idx_bottom,idx_ringdown]=detec_bottom_algo_v4(trans_obj,...
            'denoised',p.Results.denoised,...
            'thr_bottom',thr_bottom,...
            'thr_backstep',thr_backstep,...
            'r_min',r_min,...
            'r_max',r_max,...
            'thr_cum',p.Results.thr_cum,...
            'thr_echo',p.Results.thr_echo,...
            'shift_bot',shift_bot,...
            'rm_rd',1,...
            'load_bar_comp',p.Results.load_bar_comp);
end


%% BS Analysis
if BS_std_bool>0
    
    % Bottom is the sample corresponding to the bottom detect
    % BS_bottom is the backscatter level of the sample corresponding to the bottom detection
    BS_bottom(Bottom<start_sample) = nan;
    BS_bottom_analysis = BS_bottom;
    BS_bottom_analysis(isnan(Bottom)) = nan;
    
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
    idx_bottom_bs_eval(nansum(Double_bottom_region)==0) = 1;
    idx_bottom_bs_eval(isnan(Bottom)) = 1;
    idx_bottom_bs_eval(isnan(BS_bottom)) = 1;
    
else
    
    idx_bottom_bs_eval = ones(1,nb_pings);
    
end

Bottom(nansum(Double_bottom_region)==0) = nan;
idx_bottom(nansum(Double_bottom_region)==0) = nan;



%% Removing noisy pings

idx_spikes_Below = ones(1,nb_pings);
idx_spikes_Above = ones(1,nb_pings);

if Above||Below
    
    idx_noise_analysis_above = nan(nb_samples,nb_pings);
    idx_noise_analysis_below = nan(nb_samples,nb_pings);
    [I_bottom,J_bottom] = find(~isnan(idx_bottom));
    I_bottom(I_bottom>nb_samples) = nb_samples;
    J_double_bottom = [J_bottom ; J_bottom ; J_bottom];
    I_double_bottom = [I_bottom ; 2*I_bottom ; 2*I_bottom+1];
    I_double_bottom(I_double_bottom > nb_samples) = nan;
    idx_double_temp = I_double_bottom(~isnan(I_double_bottom))+nb_samples*(J_double_bottom(~isnan(I_double_bottom))-1);
    idx_double_bottom = repmat((1:nb_samples)',1,nb_pings);
    idx_samples = nan(nb_samples,nb_pings);
    idx_samples(idx_double_temp) = 1;
    idx_double_bottom = idx_samples.*idx_double_bottom;
    
    if Above
        idx_noise_analysis_above = double(bsxfun(@lt,(1:nb_samples)',nanmin(idx_bottom)));
        idx_noise_analysis_above(~idx_noise_analysis_above) = nan;
        idx_noise_analysis_above(1:start_sample,:) = nan;
    end
    
    if Below
        idx_noise_analysis_below = double(bsxfun(@gt,(1:nb_samples)',nanmax(idx_bottom))&isnan(idx_double_bottom));
        idx_noise_analysis_below(~idx_noise_analysis_below) = nan;
        idx_noise_analysis_below(1:start_sample,:) = nan;
    end
    
    idx_bottom_temp = double(~isnan(idx_bottom));
    idx_bottom_temp(idx_bottom_temp==0) = nan;
    
    Sv_lin = 10.^(Sv/20);
    Sv_bottom_max = nanmax(20*log10(filter2(ones(2*Np,b_filter(end)),Sv_lin,'same').*idx_bottom_temp/(3*Np*b_filter(end))));
    
    Norm_Val = bsxfun(@minus,Sv,Sv_bottom_max);
    Norm_Val(Norm_Val==Inf) = nan;
    
    %     thr_min_above = nan(1,nb_pings);
    %     thr_max_above = nan(1,nb_pings);
    %     thr_min_below = nan(1,nb_pings);
    %     thr_max_below = nan(1,nb_pings);
    
    
%     %%%%%%%%Version without sliding pdf%%%%%%%%%%
%     
%     
%     bins = 200;
%     
%     if Above
%         [pdf_above,y_above] = pdf_perso(Norm_Val.*idx_noise_analysis_above,'bin',bins,'win_type','gauss');
%         
%         if min(size(y_above))>1
%             [~,grad_y_above] = gradient(y_above);
%         else
%             grad_y_above = gradient(y_above);
%         end
%         [~,idx_min_above] = (nanmin(abs(cumsum(pdf_above.*grad_y_above)-thr_spikes_Above/100)));
%         [~,idx_max_above] = (nanmin(abs(cumsum(pdf_above.*grad_y_above)-(1-thr_spikes_Above/100))));
%         
%         thr_min_above = y_above(idx_min_above)*ones(1,nb_pings);
%         thr_max_above = y_above(idx_max_above)*ones(1,nb_pings);
%         
%     end
%     
%     if Below
%         [pdf_below,y_below] = pdf_perso(Norm_Val.*idx_noise_analysis_below,'bin',bins,'win_type','gauss');
%         
%         if min(size(y_below))>1
%             [~,grad_y_below] = gradient(y_below);
%         else
%             grad_y_below = gradient(y_below);
%         end
%         [~,idx_min_below] = (nanmin(abs(cumsum(pdf_below.*grad_y_below)-thr_spikes_below/100)));
%         [~,idx_max_below] = (nanmin(abs(cumsum(pdf_below.*grad_y_below)-(1-thr_spikes_below/100))));
%         
%         thr_min_below = y_below(idx_min_below)*ones(1,nb_pings);
%         thr_max_below = y_below(idx_max_below)*ones(1,nb_pings);
%         
%     end
    
    %%%%%%%%Version with sliding pdf%%%%%
    win = nanmin(300,nb_pings);
    bins = 120;
    spc = round(win/2);
    x_data = (1:nb_pings);
    
    thr_min_above = nan(1,nb_pings);
    thr_max_above = nan(1,nb_pings);
    thr_min_below = nan(1,nb_pings);
    thr_max_below = nan(1,nb_pings);
    
    if Above
        [pdf_above,x_above,y_above,~] = sliding_pdf(x_data,Norm_Val.*idx_noise_analysis_above,win,bins,spc,0);
        if min(size(y_above))>1
            [~,grad_y_above] = gradient(y_above);
        else
            grad_y_above = gradient(y_above);
        end
        [~,idx_min_above] = (nanmin(abs(cumsum(pdf_above.*grad_y_above)-thr_spikes_Above/100)));
        [~,idx_max_above] = (nanmin(abs(cumsum(pdf_above.*grad_y_above)-(1-thr_spikes_Above/100))));
        for i = 1:nb_pings
            [~,idx_x] = nanmin(abs(i-x_above(1,:)));
            thr_min_above(i) = y_above(idx_min_above(idx_x),idx_x);
            thr_max_above(i) = y_above(idx_max_above(idx_x),idx_x);
        end
    end
    
    if Below
        [pdf_below,x_below,y_below,~] = sliding_pdf(x_data,Norm_Val.*idx_noise_analysis_below,win,bins,spc,0);
        if min(size(y_above))>1
            [~,grad_y_below] = gradient(y_below);
        else
            grad_y_below = gradient(y_below);
        end
        [~,idx_min_below] = (nanmin(abs(cumsum(pdf_below.*grad_y_below)-thr_spikes_Below/100)));
        [~,idx_max_below] = (nanmin(abs(cumsum(pdf_below.*grad_y_below)-(1-thr_spikes_Below/100))));
        
        for i = 1:nb_pings
            [~,idx_x] = nanmin(abs(i-x_below(1,:)));
            thr_min_below(i) = y_below(idx_min_below(idx_x),idx_x);
            thr_max_below(i) = y_below(idx_max_below(idx_x),idx_x);
        end
    end
    
    thr_spikes = 0.1;
    
    if Below
        idx_below_max = bsxfun(@ge,Norm_Val.*idx_noise_analysis_below,thr_max_below);
        idx_below_min = bsxfun(@le,Norm_Val.*idx_noise_analysis_below,thr_min_below);
        thr_spikes_Below_vec = nansum(idx_noise_analysis_below).*(thr_spikes_Below/100+thr_spikes);
        idx_spikes_Below = nansum(idx_below_max)<thr_spikes_Below_vec&nansum(idx_below_min)<thr_spikes_Below_vec;
        idx_spikes_Below(nansum(idx_noise_analysis_below)==0) = 1;
    else
        idx_spikes_Below = ones(1,nb_pings);
    end
    
    if Above
        idx_above_max = bsxfun(@ge,Norm_Val.*idx_noise_analysis_above,thr_max_above);
        idx_above_min = bsxfun(@le,Norm_Val.*idx_noise_analysis_above,thr_min_above);
        thr_spikes_Above_vec = nansum(idx_noise_analysis_above).*(thr_spikes_Above/100+thr_spikes);
        idx_spikes_Above = nansum(idx_above_max)<thr_spikes_Above_vec&nansum(idx_above_min)<thr_spikes_Above_vec;
        idx_spikes_Above(nansum(idx_noise_analysis_above)==0) = 1;
        idx_spikes_Above(Bottom<=start_sample) = 1;
    else
        idx_spikes_Above = ones(1,nb_pings);
    end
    
end


%%%%%%And compile the final vector designing the bad pings%%%%%%%%%%%%%%%%
idx_noise_sector=~(idx_spikes_Below&idx_spikes_Above&idx_bottom_bs_eval&idx_ringdown);

%%%%%%%%%%%%%Remove isolated "good" pings%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idx_noise_sector_filter = filter(ones(1,9),1,idx_noise_sector/9);
idx_noise_sector(idx_noise_sector_filter>=7/9) = 1;

bad_pings_percent = nansum(idx_noise_sector)/nb_pings*100;
disp([num2str(bad_pings_percent) '% of bad pings']);

% bad_trans = figure('Position',[260,300,900,500]);
% set(bad_trans,'Name','Bad Transmit','NumberTitle','off');
% clf;
% plot((1:nb_pings),~idx_bottom_bs_eval,'-r+','linewidth',2);
% hold on;
% plot((1:nb_pings),~idx_ringdown,'-go','linewidth',2,'linewidth',2);
% plot((1:nb_pings),~idx_spikes_Above,'-cx','linewidth',2);
% plot((1:nb_pings),~idx_spikes_Below,'-kv','linewidth',2);
% grid on;
% set (gca,'fontsize',14);
% xlabel('Ping Number');
% legend('From BS','From RD zone','From WaterColumn Level Above','From WaterColumn Level Below','Location', 'SouthEast');
% ylim([-0.2 1.2])
% close(bad_trans);

end