function load_bot_regs(layer,varargin)
p = inputParser;

addRequired(p,'layer',@(obj) isa(obj,'layer_cl'));
addParameter(p,'bot_ver',1);
addParameter(p,'reg_ver',1);
addParameter(p,'IDs',[]);
addParameter(p,'Frequencies',[]);
parse(p,layer,varargin{:});




if p.Results.bot_ver>0
    layer.add_bottoms_from_bot_xml('Frequencies',p.Results.Frequencies);
end

if p.Results.reg_ver>0
    layer.add_regions_from_reg_xml(p.Results.IDs,'Frequencies',p.Results.Frequencies);
end

end
