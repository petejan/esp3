function output_struct= apply_algo(trans_obj,algo_name,varargin)
names={'BottomDetectionV2','BottomDetection','BadPings','Denoise','SchoolDetection','SingleTarget','TrackTarget'};

p = inputParser;

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addRequired(p,'algo_name',@(x) nansum(strcmpi(x,names))>0);
addParameter(p,'idx_r',[],@isnumeric);
addParameter(p,'idx_pings',[],@isnumeric);
addParameter(p,'load_bar_comp',[]);

parse(p,trans_obj,algo_name,varargin{:});

[idx_alg,alg_found]=find_algo_idx(trans_obj,algo_name);

if alg_found==0
    algo_obj=init_algos(algo_name);
    trans_obj.add_algo(algo_obj);
else
    algo_obj=trans_obj.Algo(idx_alg);
end

if isfield(algo_obj.Varargin,'idx_r')
    algo_obj.Varargin.idx_r=p.Results.idx_r;
end

if isfield(algo_obj.Varargin,'idx_pings')
    algo_obj.Varargin.idx_pings=p.Results.idx_pings;
end

str_eval=[];
fields_algo_in=fields(algo_obj.Varargin);

for i=1:length(fields_algo_in)
    str_eval=[str_eval sprintf('''%s'',',fields_algo_in{i})];
    if ischar(algo_obj.Varargin.(fields_algo_in{i}))
        str_eval=[str_eval sprintf('''%s'',',algo_obj.Varargin.(fields_algo_in{i}))];
    else
        str_eval=[str_eval '['];
        str_eval=[str_eval sprintf('%f ',algo_obj.Varargin.(fields_algo_in{i}))];
        str_eval=[str_eval '],'];
    end
end

str_eval(end)=[];

str_output=[];
fields_algo_out=algo_obj.Varargout;

for i=1:length(fields_algo_out)
    str_output=[str_output sprintf('%s ',fields_algo_out{i})];
end
str_output(end)=[];

if ~isempty(p.Results.load_bar_comp)
    p.Results.load_bar_comp.status_bar.setText(sprintf('Applying %s on %.0f kHz\n',algo_name,trans_obj.Config.Frequency/1e3));
else
    fprintf('Applying %s on %.0f kHz\n',algo_name,trans_obj.Config.Frequency/1e3);
end

eval(['[' str_output ']=feval(init_func(algo_obj.Name),trans_obj,''load_bar_comp'',p.Results.load_bar_comp,',str_eval ');']);

if ~isempty(p.Results.load_bar_comp)
    p.Results.load_bar_comp.status_bar.setText('');
    set(p.Results.load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',100, 'Value',0);
end

for i=1:length(fields_algo_out)
    output_struct.(fields_algo_out{i})=eval(fields_algo_out{i});
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
        
        trans_obj.Bottom=bottom_cl('Origin','Algo_v2_bp',...
            'Sample_idx',bottom,...
            'Tag',tag);
    case 'Denoise'
        if ~isempty(power_unoised)
            trans_obj.Data.replace_sub_data('powerdenoised',power_unoised);
            trans_obj.Data.replace_sub_data('spdenoised',Sp_unoised);
            trans_obj.Data.replace_sub_data('svdenoised',Sv_unoised);
            trans_obj.Data.replace_sub_data('snr',SNR);
        end
    case 'SchoolDetection'
        trans_obj.rm_region_name_idx_r_idx_p('School',p.Results.idx_r,p.Results.idx_pings);
        trans_obj.create_regions_from_linked_candidates(linked_candidates,'w_unit','meters','h_unit','meters','cell_w',20,'cell_h',10);
    case 'SingleTarget'
        trans_obj.set_ST(single_targets);
    case 'TrackTarget'
        trans_obj.Tracks=tracks_out;
end


end

