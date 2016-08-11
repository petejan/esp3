function output_struct= apply_algo(trans_obj,algo_name,varargin)
names={'BottomDetection','BadPings','Denoise','SchoolDetection','SingleTarget','TrackTarget'};

p = inputParser;

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addRequired(p,'algo_name',@(x) nansum(strcmpi(x,names))>0);

parse(p,trans_obj,algo_name,varargin{:});

[idx_alg,alg_found]=find_algo_idx(trans_obj,algo_name);
if alg_found==0
    algo_obj=init_algos(algo_name);
    trans_obj.add_algo(algo_obj);
else
    algo_obj=trans_obj.Algo(idx_alg);
end

str_eval=[];
fields_algo_in=fields(algo_obj.Varargin);

for i=1:length(fields_algo_in)
    if ischar(algo_obj.Varargin.(fields_algo_in{i}))
        str_eval=[str_eval sprintf('''%s'',''%s'',',fields_algo_in{i},algo_obj.Varargin.(fields_algo_in{i}))];
    else
        str_eval=[str_eval sprintf('''%s'',%f,',fields_algo_in{i},algo_obj.Varargin.(fields_algo_in{i}))];
    end
end
str_eval(end)=[];

str_output=[];
fields_algo_out=algo_obj.Varargout;

for i=1:length(fields_algo_out)
    str_output=[str_output sprintf('%s ',fields_algo_out{i})];
end
str_output(end)=[];

fprintf('Applying %s on %.0f kHz\n',algo_name,trans_obj.Config.Frequency/1e3);
eval(['[' str_output ']=feval(init_func(algo_obj.Name),trans_obj,' str_eval ');']);

for i=1:length(fields_algo_out)
    output_struct.(fields_algo_out{i})=eval(fields_algo_out{i});
end

switch algo_name
    case'BottomDetection'
        range=trans_obj.Data.get_range();
        bottom_range=nan(size(bottom));
        bottom_range(~isnan(bottom))=range(bottom(~isnan(bottom)));
        old_tag=trans_obj.Bottom.Tag;
        
        trans_obj.setBottom(bottom_cl('Origin','Algo_v3',...
            'Range', bottom_range,...
            'Sample_idx',bottom,...
            'Tag',old_tag,'Shifted',algo_obj.Varargin.shift_bot));
    case 'BadPings'
        range=trans_obj.Data.get_range();
        bottom_range=nan(size(bottom));
        bottom_range(~isnan(bottom))=range(bottom(~isnan(bottom)));
        
        tag=double(idx_noise_sector==0);
        
        trans_obj.Bottom=bottom_cl('Origin','Algo_v2_bp',...
            'Range', bottom_range,...
            'Sample_idx',bottom,...
            'Tag',tag,'Shifted',algo_obj.Varargin.shift_bot);
    case 'Denoise'
        if ~isempty(power_unoised)
            trans_obj.Data.add_sub_data('powerdenoised',power_unoised);
            trans_obj.Data.add_sub_data('spdenoised',Sp_unoised);
            trans_obj.Data.add_sub_data('svdenoised',Sv_unoised);
            trans_obj.Data.add_sub_data('snr',SNR);
        end
    case 'SchoolDetection'
        trans_obj.rm_region_name('School');
        trans_obj.create_regions_from_linked_candidates(linked_candidates,'w_unit','meters','h_unit','meters','cell_w',20,'cell_h',10);
    case 'SingleTarget'
        trans_obj.set_ST(single_targets);
    case 'TrackTarget'
        trans_obj.Tracks=tracks_out;
end

fprintf('Done\n\n');

end

