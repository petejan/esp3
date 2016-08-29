function [header,output,type]=read_xml0_OLD2(t_line)
header=[];
output=[];

xstruct=parseXMLStr(t_line);
type=xstruct.Name;
switch type
    case'Configuration'
        [header,output]=read_config_xstruct(xstruct);
    case 'Environment'
        env_temp=read_env_xstruct(xstruct);
        output=env_temp;
    case 'Parameter'
        output=read_params_xstruct(xstruct);

end
