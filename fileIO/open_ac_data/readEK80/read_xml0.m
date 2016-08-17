function [header,output,type]=read_xml0(t_line)
header=[];
output=[];


xstruct=xml2struct(t_line);
type_tmp=fields(xstruct);
type=type_tmp{1};
switch type
    case'Configuration'
        [header,output]=read_config_xstruct_v2(xstruct);
    case 'Environment'
        output=read_env_xstruct_v2(xstruct);
    case 'Parameter'
        output=read_params_xstruct_v2(xstruct);
end


end