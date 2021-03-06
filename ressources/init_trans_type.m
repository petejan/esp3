function [type_cell,descr_cell]=init_trans_type()

try
    app_path_main=whereisEcho();
    config_path=fullfile(app_path_main,'config');
    [type_cell,descr_cell]=read_type_xml(fullfile(config_path,'types.xml'));   
catch err
     warning('Could not read types.xml_files in your config folder...');
    disp(err.message);
    type_cell={' ' 'Acoustic' 'Trawl' 'MW_trawl' 'ID_trawl' 'Steam' 'Mooring' 'Calibration' 'Deployement'};
    descr_cell=cell(1,numel(type_cell));
end



end