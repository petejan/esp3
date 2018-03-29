function  populate_ac_db_from_folder(main_figure,path_f)

show_status_bar(main_figure);

ac_db_filename=fullfile(path_f,'ac_db_test.db');

create_ac_database(ac_db_filename,1);

dir_raw=dir(fullfile(path_f,'*.raw'));
%dir_asl=dir(fullfile(path_f,'*.*A'));
%list_raw=union({dir_raw([dir_raw(:).isdir]==0).name},{dir_asl([dir_asl(:).isdir]==0).name});

list_raw={dir_raw([dir_raw(:).isdir]==0).name};

Filenames=fullfile(path_f,list_raw);

%file_pkeys=add_files_to_t_file(ac_db_filename,Filenames,'file_path',path_f);

load_bar_comp=getappdata(main_figure,'Loading_bar');

all_layer=open_EK_file_stdalone(Filenames,'GPSOnly',1,'load_bar_comp',load_bar_comp);

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
cruise_or_deployment_pkey=cell(1,numel(new_layers));
cruise_pkey=cell(1,numel(new_layers));
deployment_pkey=cell(1,numel(new_layers));
platform_type_pkey=cell(1,numel(new_layers));
transducer_pkey=cell(1,numel(new_layers));
transceiver_pkey=cell(1,numel(new_layers));
transducer_location_type_pkey=cell(1,numel(new_layers));
transducer_orientation_type_pkey=cell(1,numel(new_layers));

calibration_pkey=cell(1,numel(new_layers));
parameters_pkeys=cell(1,numel(new_layers));

transect_pkeys=cell(1,numel(new_layers));
file_pkeys=cell(1,numel(new_layers));

for ilay=1:length(new_layers)
    lay_obj=new_layers(ilay);
    gps_data=lay_obj.GPSData;
    
    [start_time,end_time]=lay_obj.get_time_bound_files();
    file_pkeys{ilay}=add_files_to_t_file(ac_db_filename,lay_obj.Filename,'file_path',path_f);
    %file_pkeys{ilay}=get_file_pkeys_from_ac_db(ac_db_filename,lay_obj.Filename);
    
    if ~isempty(gps_data)        
%         depth=lay_obj.Transceivers(1).get_bottom_depth(); 
%         depth_re=resample_data_v2(depth,lay_obj.Transceivers(1).Time,gps_data.Time);
%         
        depth_re=nan(1,numel(gps_data.Time));
        for ifi=1:length(file_pkeys{ilay})
            idx_keep=gps_data.Time>=start_time(ifi)&gps_data.Time<=end_time(ifi);
            if any(idx_keep)
                add_nav_to_t_navigation(ac_db_filename,...
                    'navigation_file_key',file_pkeys{ilay}{ifi},...
                    'navigation_time',gps_data.Time(idx_keep),...
                    'navigation_latitude',gps_data.Lat(idx_keep),...
                    'navigation_longitude',gps_data.Long(idx_keep),...
                    'navigation_depth',depth_re(idx_keep),...
                    'navigation_comments',gps_data.NMEA);
            end
            nb_trans=numel(lay_obj.Transceivers);
            parameters_pkeys{ilay}=nan(1,nb_trans);
            for itrans=1:nb_trans
                params=lay_obj.Transceivers(itrans).Params;
                
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
                   parameters_pkeys{ilay}(itrans)=p_temp{1};
                end
            end
        end
    end
       
    ac_db_struct=survey_data_obj_to_ac_db_struct({lay_obj.SurveyData});
    transect_pkeys{ilay}=add_transects_to_t_transect(ac_db_filename,ac_db_struct);
    calibration_pkey{ilay}=add_calibration_to_t_calibration(ac_db_filename);
end

hide_status_bar(main_figure);
% 
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