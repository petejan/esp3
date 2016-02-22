function [layers,layer]=shuffle_layers(layers,new_layers_in,varargin)

p = inputParser;

addRequired(p,'layers',@(obj) isa(obj,'layer_cl')||isempty(obj));
addRequired(p,'new_layers_in',@(obj) isa(obj,'layer_cl')||isempty(obj));
addParameter(p,'multi_layer',1);
addParameter(p,'join',0);
addParameter(p,'keep',0);

parse(p,layers,new_layers_in,varargin{:});

multi_layer=p.Results.multi_layer;
join=p.Results.join;
keep=p.Results.keep;

for i=1:length(layers)
    if ~isvalid(layers(i))
        layers(i)=[];
    end
end

shuffling_box=msgbox('Shuffling layers... This window will close when finished...','Shuffling layers','modal');

if ~isempty(layers)
    [~,found]=find_layer_idx(layers,0);
else
    found=0;
    if length(new_layers_in)==1
        layers=new_layers_in;
        layer=new_layers_in;
        layer.load_echo_logbook();
        try
            close(shuffling_box);
        end
        return;
    end
end

if  found==1
    layers=layers.delete_layers(0);
end

[~,found]=find_layer_idx(new_layers_in,0);

if  found==1
    new_layers_in=new_layers_in.delete_layers(0);
end

if multi_layer<=0
    
    if join==1
        new_layers_in=[layers new_layers_in];
        layers=[];
    end
    
 new_layers_out=rearrange_layers(new_layers_in,multi_layer);
    
else
    new_layers_out=new_layers_in;
end

for ilay=1:length(new_layers_out)
    new_layers_out(ilay).load_echo_logbook();
end

for u=1:length(new_layers_out)
    layer=new_layers_out(u);
    if ~isempty(layers)
        [~,found]=find_layer_idx(layers,layer.ID_num);
    else
        found=0;
    end
    
    if found==1
        warning('Who, that''s extremely unlikely! There has been a problem in the shuffling process. This programm will crash very soon.');
    else
        layers=[layers layer];
    end
end

layers=reorder_layers_time(layers);

try
    close(shuffling_box);
end

end

