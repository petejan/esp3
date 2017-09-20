%% apply_algo.m
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
% * |algo_name|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |output_struct|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function output_struct= apply_algo(trans_obj,algo_name,varargin)

names={'BottomDetectionV2','BottomDetection','BadPings','BadPingsV2','Denoise','SchoolDetection','SingleTarget','TrackTarget'};

p = inputParser;

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addRequired(p,'algo_name',@(x) nansum(strcmpi(x,names))>0);
addParameter(p,'replace_bot',1,@isnumeric);
addParameter(p,'reg_obj',region_cl.empty(),@(x) isa(x,'region_cl'));
addParameter(p,'load_bar_comp',[]);

parse(p,trans_obj,algo_name,varargin{:});

[idx_alg,alg_found]=find_algo_idx(trans_obj,algo_name);

if alg_found==0
    algo_obj=init_algos(algo_name);
    trans_obj.add_algo(algo_obj);
else
    algo_obj=trans_obj.Algo(idx_alg);
end


[str_eval,str_output]=algo_obj.get_str_for_eval();

if isfield(algo_obj.Varargin,'reg_obj')
    str_eval=[str_eval ',''reg_obj'',p.Results.reg_obj'];
end

if ~isempty(p.Results.load_bar_comp)
    p.Results.load_bar_comp.status_bar.setText(sprintf('Applying %s on %.0f kHz\n',algo_name,trans_obj.Config.Frequency/1e3));
end

eval(['[' str_output ']=feval(init_func(algo_obj.Name),trans_obj,''load_bar_comp'',p.Results.load_bar_comp,',...
    str_eval ');']);

if ~isempty(p.Results.load_bar_comp)
    p.Results.load_bar_comp.status_bar.setText('');
    set(p.Results.load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',100, 'Value',0);
end

for i=1:length(algo_obj.Varargout)
    output_struct.(algo_obj.Varargout{i})=eval(algo_obj.Varargout{i});
end

switch algo_name
    case'BottomDetection'
        old_tag=trans_obj.Bottom.Tag;
        trans_obj.setBottom(bottom_cl('Origin','Algo_v3',...
            'Sample_idx',bottom,...
            'Tag',old_tag));
    case'BottomDetectionV2'
        old_tag=trans_obj.Bottom.Tag;
        trans_obj.setBottom(bottom_cl('Origin','Algo_v4',...
            'Sample_idx',bottom,...
            'Tag',old_tag));
    case 'BadPings'
        tag=double(idx_noise_sector==0);
        if p.Results.replace_bot==0
            war_str=('Update bottom');
            choice = questdlg('New bottom has been detected? Do you want to use it?',...
                war_str,...
                'Yes','No', ...
                'Yes');
            % Handle response
            switch choice
                case 'Yes'
                    new_bot=bottom_cl('Origin','Algo_v2_bp',...
                        'Sample_idx',bottom,...
                        'Tag',tag);
                case 'No'
                    new_bot=trans_obj.Bottom;
                    new_bot.Tag=tag;
            end
        else
            new_bot=bottom_cl('Origin','Algo_v2_bp',...
                'Sample_idx',bottom,...
                'Tag',tag);
        end
        trans_obj.setBottom(new_bot);
    case 'BadPingsV2'        
         tag=trans_obj.Bottom.Tag;
         if isempty(p.Results.idx_pings)
             tag=ones(size(tag));
         end
        tag(idx_noise_sector)=0;
        
        new_bot=bottom_cl('Origin','Algo_v3_bp',...
            'Sample_idx',trans_obj.get_bottom_idx(),...
            'Tag',tag);
        trans_obj.setBottom(new_bot);
    case 'Denoise'
        if ~isempty(power_unoised)
            trans_obj.Data.replace_sub_data('powerdenoised',power_unoised);
            trans_obj.Data.replace_sub_data('spdenoised',Sp_unoised);
            trans_obj.Data.replace_sub_data('svdenoised',Sv_unoised);
            trans_obj.Data.replace_sub_data('snr',SNR);
        end
    case 'SchoolDetection'
        
        if isempty(p.Results.reg_obj)
            idx_r=1:length(trans_obj.get_transceiver_range());
            idx_pings=1:length(trans_obj.get_transceiver_pings());
            
        else
            idx_pings=p.Results.reg_obj.Idx_pings;
            idx_r=p.Results.reg_obj.Idx_r;
            
        end
        
        dd=nanmean(diff(trans_obj.GPSDataPing.Dist(idx_pings)));
     
        dr=nanmean(diff(trans_obj.get_transceiver_range(idx_r)));
        
        if dd>0
            w_unit='meters';
            cell_w=nanmax(algo_obj.Varargin.l_min_can/2,2*dd);
        else
            w_unit='pings';
            cell_w=round(nanmax(algo_obj.Varargin.l_min_can/2,2*dd));
        end
        
        
        trans_obj.rm_region_name_idx_r_idx_p('School',idx_r,idx_pings);
        if ~isempty(p.Results.load_bar_comp)
             p.Results.load_bar_comp.status_bar.setText('Creating regions');
        end
        trans_obj.create_regions_from_linked_candidates(linked_candidates,'w_unit',w_unit,'h_unit','meters',...
            'cell_w',cell_w,'cell_h',nanmax(dr*2,algo_obj.Varargin.h_min_can/10));
    case 'SingleTarget'
        trans_obj.set_ST(single_targets);
    case 'TrackTarget'
        trans_obj.Tracks=tracks_out;
end


end

