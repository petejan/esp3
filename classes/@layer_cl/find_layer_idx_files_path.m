function [idx_lays,found]=find_layer_idx_files_path(layers,filenames,varargin)

p = inputParser;

addRequired(p,'layers',@(obj) isa(obj,'layer_cl'));
addRequired(p,'filenames',@(x) iscell(x)||ischar(x));
addParameter(p,'Frequencies',[]);

parse(p,layers,filenames,varargin{:});


if~iscell(filenames)
    filenames={filenames};
end

[filenames_lays,layer_IDs]=layers.list_files_layers();

idx_lays=[];
for ifi=1:length(filenames)
    idx_f=find(strcmpi(filenames{ifi},filenames_lays));
    if isempty(idx_f)
        continue;
    end
    id_lays=unique(layer_IDs(idx_f));
    for i=1:length(id_lays)
        [idx_tmp,found_id]=layers.find_layer_idx(id_lays(i));
        
        if found_id==1
            if isempty(p.Results.Frequencies)
                idx_lays=[idx_tmp idx_lays];
            else
                freq_bool=1;
                for ifreq=1:length(p.Results.Frequencies)
                    [~,found_freq]=find_freq_idx(layers(idx_tmp),p.Results.Frequencies(ifreq));
                    if found_freq==0
                        freq_bool=0;
                    end
                end
                if freq_bool>0
                    idx_lays=[idx_tmp idx_lays];
                end
            end
        end
    end
    
end

idx_lays=unique(idx_lays);

if isempty(idx_lays)
    idx_lays=1;
    found=0;
else
    found=1;
end

end