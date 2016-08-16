function [header,output,type]=read_xml0(t_line)
header=[];
output=[];
type='';
% fid_xml=fopen(fullfile(tempdir,'xml0.xml'),'w');
% fprintf(fid_xml,'%s',t_line);
% fclose(fid_xml);
% 
% xstruct=parseXMLStr(fullfile(tempdir,'xml0.xml'));
% 
% delete(fullfile(tempdir,'xml0.xml'));

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

end