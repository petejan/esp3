function [ver_bot_loaded,ver_reg_loaded,comment]=load_bot_regs(layer,varargin)
p = inputParser;

addRequired(p,'layer',@(obj) isa(obj,'layer_cl'));
addParameter(p,'bot_ver',-1);%-1:load current xml file; 0: load latest db version; n: load closest version to version n from db
addParameter(p,'reg_ver',-1);%-1:load current xml file; 0: load latest db version; n: load closest version to version n from db
addParameter(p,'IDs',[]);
addParameter(p,'Frequencies',[]);
parse(p,layer,varargin{:});

ver_bot_loaded=p.Results.bot_ver;
if ~isempty(p.Results.bot_ver)
    if p.Results.bot_ver>=0
        ver_bot_loaded=layer.create_bot_xml_from_db('bot_ver',p.Results.bot_ver);
    end
    layer.add_bottoms_from_bot_xml('Frequencies',p.Results.Frequencies,'Version',ver_bot_loaded);
    fprintf('Bottom version %d loaded\n',ver_bot_loaded);

end

ver_reg_loaded=p.Results.reg_ver;
comment='';
%profile on;
if ~isempty(p.Results.reg_ver)
    if p.Results.reg_ver>=0
        [ver_reg_loaded,comment]=layer.create_reg_xml_from_db('reg_ver',p.Results.reg_ver);
    end
    layer.add_regions_from_reg_xml([],'Frequencies',p.Results.Frequencies,'Version',ver_reg_loaded);
    fprintf('Regions version %d loaded\n',ver_reg_loaded);

end
% profile off;
% profile viewer


end
