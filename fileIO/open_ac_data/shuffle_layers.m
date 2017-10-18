function layers_out=shuffle_layers(layers_in,varargin)

p = inputParser;

addRequired(p,'layers_in',@(obj) isa(obj,'layer_cl')||isempty(obj));
addParameter(p,'multi_layer',1);

parse(p,layers_in,varargin{:});

multi_layer=p.Results.multi_layer;

if length(layers_in)==1
    layers_out=layers_in;
    return;
end

[~,found]=find_layer_idx(layers_in,0);

if  found==1
    layers_in=layers_in.delete_layers(0);
end

if multi_layer<=0
    layers_out=rearrange_layers(layers_in,multi_layer); 
else
    layers_out=layers_in;
end

end

