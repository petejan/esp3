function  populate_ac_db_from_folder(main_figure,path_f,varargin)

p = inputParser;

addRequired(p,'main_figure',@ishandle);
addRequired(p,'path_f',@ischar);
addParameter(p,'ac_db_filename','',@ischar);
addParameter(p,'platform_type','Hull',@ischar);
addParameter(p,'transducer_location_type','Hull, keel',@ischar);
addParameter(p,'transducer_orientation_type','Downward-looking',@ischar);
addParameter(p,'deployment_pkey',[],@isnumeric);
addParameter(p,'mission_pkey',[],@isnumeric);
addParameter(p,'overwrite_db',0,@isnumeric);
addParameter(p,'populate_t_navigation',1,@isnumeric);

parse(p,main_figure,path_f,varargin{:});
show_status_bar(main_figure);

if isempty(p.Results.ac_db_filename)
    ac_db_filename=fullfile(path_f,'ac_db.db');
else
    ac_db_filename=p.Results.ac_db_filename;
end

create_ac_database(ac_db_filename,p.Results.overwrite_db);

[~,platform_type_pkey]=get_cols_from_table(ac_db_filename,'t_platform_type','input_cols',{'platform_type'},'input_vals',{p.Results.platform_type},...
    'output_cols',{'platform_type_pkey'});
if isempty(platform_type_pkey)
   warning('Invalid platform_type, cannot load this mission'); 
   return;
end

[~,transducer_orientation_type_pkey]=get_cols_from_table(ac_db_filename,'t_transducer_orientation_type','input_cols',{'transducer_orientation_type'},'input_vals',{p.Results.transducer_orientation_type},...
    'output_cols',{'transducer_orientation_type_pkey'});

if isempty(transducer_orientation_type_pkey)
   warning('Invalid transducer_orientation_type, cannot load this mission'); 
   return;
end

[~,transducer_location_type_pkey]=get_cols_from_table(ac_db_filename,'t_transducer_location_type','input_cols',{'transducer_location_type'},'input_vals',{p.Results.transducer_location_type},...
    'output_cols',{'transducer_location_type_pkey'});

if isempty(transducer_location_type_pkey)
   warning('Invalid transducer_location_type, cannot load this mission'); 
   return;
end

dir_raw=dir(fullfile(path_f,'*.raw'));
dir_asl=dir(fullfile(path_f,'*.*A'));
list_raw=union({dir_raw([dir_raw(:).isdir]==0).name},{dir_asl([dir_asl(:).isdir]==0).name});

% list_raw=list_raw(max(1,numel(list_raw)-200):end-100);
% list_raw=list_raw(1:10);

Filenames=fullfile(path_f,list_raw);

%file_pkey=add_files_to_t_file(ac_db_filename,Filenames,'file_path',path_f);

load_bar_comp=getappdata(main_figure,'Loading_bar');
gps_data_files=get_ping_data_from_db(Filenames);

if p.Results.populate_t_navigation>0
    gps_data_files_t_nav=get_gps_data_cl_from_t_navigation(ac_db_filename,Filenames);
    GPS_only=cellfun(@isempty,gps_data_files)&cellfun(@isempty,gps_data_files_t_nav);
    GPS_only=~GPS_only+1;
else
    GPS_only=3*ones(1,numel(Filenames));
end

all_layer=open_EK_file_stdalone(Filenames,'GPSOnly',GPS_only,'load_bar_comp',load_bar_comp);
    
idx_gp=find(GPS_only==2);

for ilay=idx_gp
    if ~isempty(gps_data_files{ilay})
        all_layer(ilay).GPSData=gps_data_files{ilay};
    elseif ~isempty(gps_data_files_t_nav{ilay})
        all_layer(ilay).GPSData=gps_data_files_t_nav{ilay};
    end
end

all_layers_sorted=all_layer.sort_per_survey_data();

load_bar_comp.status_bar.setText('Shuffling layers');

new_layers=[];

for icell=1:length(all_layers_sorted)
    new_layers=[new_layers shuffle_layers(all_layers_sorted{icell},'multi_layer',0)];
end

if isempty(new_layers)
    return;
end

new_layers.load_echo_logbook_db();

load_bar_comp.status_bar.setText('Loading Ac db');

if isempty(p.Results.deployment_pkey)
    deployment_pkey=add_deployment_struct_to_t_deployment(ac_db_filename,'deployment_struct',init_deployment_struct());
else
    deployment_pkey{1}=p.Results.deployment_pkey;
end


setup_pkey=cell(1,numel(new_layers));

transducer_pkey=cell(1,numel(new_layers));
transceiver_pkey=cell(1,numel(new_layers));

calibration_pkey=cell(1,numel(new_layers));
parameters_pkey=cell(1,numel(new_layers));

transect_pkey=cell(1,numel(new_layers));
file_pkey=cell(1,numel(new_layers));
software_pkey=cell(1,numel(new_layers));

for ilay=1:length(new_layers)
    lay_obj=new_layers(ilay);
    
    gps_data=lay_obj.GPSData;
    
    switch lay_obj.Filetype
        case 'EK80'
            [header,~]=read_EK80_config(lay_obj.Filename{1});
            s_manu='Simrad';
            s_name=header.ApplicationName;
            s_ver=header.Version;
        case 'EK60'
            s_manu='Simrad';
            s_name='ER60';
            s_ver='?';
        case 'ASL'
            s_manu='ASL';
            s_name='ASL';
            s_ver='?';
    end
    software_pkey{ilay}=add_software_to_t_software(ac_db_filename,....
        'software_manufacturer',s_manu,...
        'software_name',s_name,...
        'software_version',s_ver,...
        'software_host','',...
        'software_install_date','',...
        'software_comments','');
    
    [start_time,end_time]=lay_obj.get_time_bound_files();
    
    file_pkey{ilay}=add_files_to_t_file(ac_db_filename,lay_obj.Filename,...
        'file_path',path_f,...
        'file_software_key',software_pkey{ilay}{1},...
        'file_start_time',start_time,...
        'file_end_time',end_time);
    
    
    %file_pkey{ilay}=get_file_pkey_from_ac_db(ac_db_filename,lay_obj.Filename);
    ac_db_struct=survey_data_obj_to_ac_db_struct({lay_obj.SurveyData});
    transect_pkey{ilay}=add_transects_to_t_transect(ac_db_filename,ac_db_struct);
    calibration_pkey{ilay}=add_calibration_to_t_calibration(ac_db_filename);
    
    if ~isempty(gps_data)
        %         depth=lay_obj.Transceivers(1).get_bottom_depth();
        %         depth_re=resample_data_v2(depth,lay_obj.Transceivers(1).Time,gps_data.Time);
        %
        depth_re=nan(1,numel(gps_data.Time));
        for ifi=1:length(file_pkey{ilay})
            idx_keep=gps_data.Time>=start_time(ifi)&gps_data.Time<=end_time(ifi);
            if any(idx_keep)
                add_nav_to_t_navigation(ac_db_filename,...
                    'navigation_file_key',file_pkey{ilay}(ifi),...
                    'navigation_time',gps_data.Time(idx_keep),...
                    'navigation_latitude',gps_data.Lat(idx_keep),...
                    'navigation_longitude',gps_data.Long(idx_keep),...
                    'navigation_depth',depth_re(idx_keep),...
                    'navigation_comments',gps_data.NMEA);
            end
        end
        nb_trans=numel(lay_obj.Transceivers);
        parameters_pkey{ilay}=nan(1,nb_trans);
        transceiver_pkey{ilay}=nan(1,nb_trans);
        transducer_pkey{ilay}=nan(1,nb_trans);
        setup_pkey{ilay}=nan(1,nb_trans);
        
        for itrans=1:nb_trans
            params=lay_obj.Transceivers(itrans).Params;
            config=lay_obj.Transceivers(itrans).Config;
            switch lay_obj.Transceivers(itrans).Mode
                case 'CW'
                    parameters_FM_pulse_type='';
                case 'FM'
                    
                    if params.FrequencyStart(1)>params.FrequencyEnd(1)
                        parameters_FM_pulse_type='linear down-sweep';
                    else
                        parameters_FM_pulse_type='linear up-sweep';
                    end
            end
            
            p_temp=add_params_to_t_parameters(ac_db_filename,...
                'parameters_pulse_mode',lay_obj.Transceivers(itrans).Mode,...
                'parameters_pulse_length',round(params.PulseLength(1)*1e6)/1e6,...
                'parameters_pulse_slope',params.Slope(1),...
                'parameters_FM_pulse_type',parameters_FM_pulse_type,...
                'parameters_frequency_min',params.FrequencyStart(1),...
                'parameters_frequency_max',params.FrequencyEnd(1),...
                'parameters_power',params.TransmitPower(1),....
                'parameters_comments',''...
                );
            if ~isempty(p_temp)
                parameters_pkey{ilay}(itrans)=p_temp{1};
            else
                 warning('Problem loading parameters'); 
            end
            
            switch config.TransceiverType
                case list_GPTs()
                    manu='Simrad';
                case list_WBTs()
                    manu='Simrad' ;
                otherwise
                    manu='';
            end
            
            transceiver_pkey_temp=add_transceiver_to_t_transceiver(ac_db_filename,...
                'transceiver_manufacturer',manu,...
                'transceiver_model',config.TransceiverType,...
                'transceiver_serial',config.SerialNumber,...
                'transceiver_frequency_lower',config.FrequencyMinimum,...
                'transceiver_frequency_nominal',config.Frequency,...
                'transceiver_frequency_upper',config.FrequencyMaximum,...
                'transceiver_firmware',num2str(config.TransceiverSoftwareVersion),...
                'transceiver_comments','');
            
            if ~isempty(transceiver_pkey_temp)
                transceiver_pkey{ilay}(itrans)=transceiver_pkey_temp{1};
            else
                 warning('Problem loading transceiver'); 
            end
            
            switch config.BeamType
                case 1
                    bt='Single-beam, split-aperture';
                case 0
                    bt='Single-beam';
                    
            end
            [~,transducer_beam_type_pkey]=get_cols_from_table(ac_db_filename,'t_transducer_beam_type','input_cols',{'transducer_beam_type'},'input_vals',{bt},...
                'output_cols',{'transducer_beam_type_pkey'});
            
            
            transducer_pkey_temp=add_transducer_to_t_transducer(ac_db_filename,...
                'transducer_manufacturer',manu,...
                'transducer_model',deblank(config.TransducerName),...
                'transducer_beam_type_key',transducer_beam_type_pkey{1},...
                'transducer_serial',config.TransducerSerialNumber,...
                'transducer_frequency_lower',config.FrequencyMinimum,...
                'transducer_frequency_nominal',config.Frequency,...
                'transducer_frequency_upper',config.FrequencyMaximum,...
                'transducer_psi',round(config.EquivalentBeamAngle*1e2)/1e2,...,...
                'transducer_beam_angle_major',round(config.BeamWidthAlongship*1e2)/1e2,...
                'transducer_beam_angle_minor',round(config.BeamWidthAthwartship*1e2)/1e2,...
                'transducer_comments','');
            
            if ~isempty(transducer_pkey_temp)
                transducer_pkey{ilay}(itrans)=transducer_pkey_temp{1};
            else
                 warning('Problem loading transducer'); 
            end
            
            setup_pkey_temp=add_setup_to_t_setup(ac_db_filename,...
                'setup_platform_type_key',platform_type_pkey{1},...
                'setup_calibration_key', calibration_pkey{ilay}{1},...
                'setup_parameters_key',parameters_pkey{ilay}(itrans),...
                'setup_transducer_key',transducer_pkey{ilay}(itrans),...
                'setup_transceiver_key', transceiver_pkey{ilay}(itrans),...
                'setup_transducer_location_type_key',transducer_location_type_pkey{1},...
                'setup_transducer_location_x',config.TransducerOffsetX,...
                'setup_transducer_location_y',config.TransducerOffsetY,...
                'setup_transducer_location_z',config.TransducerOffsetZ,...
                'setup_transducer_depth',config.TransducerOffsetX,...
                'setup_transducer_orientation_type_key',transducer_orientation_type_pkey{1},...
                'setup_transducer_orientation_vx',config.TransducerAlphaX,...
                'setup_transducer_orientation_vy',config.TransducerAlphaY,...
                'setup_transducer_orientation_vz',config.TransducerAlphaZ,...
                'setup_comments','');
            
            if ~isempty(setup_pkey_temp)
                setup_pkey{ilay}(itrans)=setup_pkey_temp{1};
            else
                 warning('Problem loading setup'); 
            end
        end
        
    end
    add_many_to_many(ac_db_filename,'t_file_setup','file_key','setup_key',file_pkey{ilay},setup_pkey{ilay});
    add_many_to_many(ac_db_filename,'t_deployment_setup','deployment_key','setup_key',deployment_pkey{1},setup_pkey{ilay});
end

if ~isempty(p.Results.mission_pkey)
    for i_mission=1:numel(p.Results.mission_pkey)
        add_many_to_many(ac_db_filename,'t_mission_deployment','deployment_key','mission_key',deployment_pkey{1},p.Results.mission_pkey(i_mission));
    end
end
file_pkeys=cell2mat(file_pkey')';
[lat_min,lat_max,lon_min,lon_max]=get_lat_lon_min_max_from_file_pkey(ac_db_filename,file_pkeys);
%[t_min,t_max]=get_t_min_max_from_file_pkey(ac_db_filename,file_pkeys);

sql_query=sprintf('UPDATE t_deployment SET deployment_northlimit=%f,deployment_southlimit=%f,deployment_eastlimit=%f,deployment_westlimit=%f',lat_max,lat_min,lon_max,lon_min);
dbconn=sqlite(ac_db_filename,'connect');
dbconn.exec(sql_query);
dbconn.close();

hide_status_bar(main_figure);


% map_obj=map_input_cl.map_input_cl_from_obj(new_layers);
%
% hfigs=getappdata(main_figure,'ExternalFigures');
%
% hfig=new_echo_figure([],'Tag','nav');
% map_obj.display_map_input_cl('hfig',hfig,'main_figure',main_figure,'oneMap',1);
%
% hfigs=[hfigs hfig];
% setappdata(main_figure,'ExternalFigures',hfigs);

end