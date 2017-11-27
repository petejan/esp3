
function load_default_params(src,main_figure,algo_name)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,~]=layer.get_trans(curr_disp);

[idx_algo,found]=find_algo_idx(trans_obj,algo_name);
if found==0
    return
end

[~,~,algo_files]=get_config_files(algo_name);
[~,algo_alt,names]=read_config_algo_xml(algo_files{1});

if strcmp(src.String{src.Value},'--')
    return;
end

idx_algo_xml=strcmpi(names,src.String{src.Value});

if ~isempty(idx_algo_xml)
    fields_to_up=fields(algo_alt(idx_algo_xml).Varargin);
    
    for i=1:numel(fields_to_up)
        if isfield(trans_obj.Algo(idx_algo).Varargin,(fields_to_up{i}))&&~ismember(fields_to_up{i},{'depth_min','depth_max','reg_obj','r_min','r_max'})
            trans_obj.Algo(idx_algo).Varargin.(fields_to_up{i})=algo_alt(idx_algo_xml).Varargin.(fields_to_up{i});
        end
    end
end
setappdata(main_figure,'Layer',layer);

end
