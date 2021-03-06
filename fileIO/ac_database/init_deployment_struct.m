function deployment_struct=init_deployment_struct()

deployment_struct=struct('deployment_type_key',1,...
'deployment_ship_key',1,...
'deployment_name','',...
'deployment_id','',...
'deployment_description','',...
'deployment_area_description','',...
'deployment_summary_report','',...
'deployment_operator','',...
'deployment_start_date',now,...
'deployment_end_date',now,...
'deployment_northlimit',90,...
'deployment_eastlimit',180,...
'deployment_southlimit',-90,...
'deployment_westlimit',-180,...
'deployment_uplimit',0,...
'deployment_downlimit',-12000,...
'deployment_units','latlon',...
'deployment_zunits','meters',...
'deployment_projection','wgs84',...
'deployment_start_port','Wellington',...
'deployment_end_port','Wellington',...
'deployment_start_BODC_code','Wellington',...
'deployment_end_BODC_code','Wellington',...
'deployment_comments','');