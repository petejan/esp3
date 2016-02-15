function save_bot_regs(layer_obj,varargin)

p = inputParser;

addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
addParameter(p,'save_regs',1);
addParameter(p,'save_bot',1);

parse(p,layer_obj,varargin{:});
if p.Results.save_regs>0
    layer_obj.write_reg_to_reg_xml();
end
if p.Results.save_bot>0
    layer_obj.write_bot_to_bot_xml()
end

end