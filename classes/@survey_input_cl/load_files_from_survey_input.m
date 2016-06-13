function layers=load_files_from_survey_input(surv_input_obj,varargin)

p = inputParser;

addRequired(p,'surv_input_obj',@(obj) isa(obj,'survey_input_cl'));

addParameter(p,'PathToMemmap','',@ischar)

parse(p,surv_input_obj,varargin{:});

datapath=p.Results.PathToMemmap;
options=surv_input_obj.Options;
regions_wc=surv_input_obj.Regions_WC;
algos=surv_input_obj.Algos;
cal=surv_input_obj.Cal;


% [~,files_to_load]=surv_input_obj.check_n_complete_input();

snapshots=surv_input_obj.Snapshots;

layers=layer_cl.empty();
for isn=1:length(snapshots)
    snap_num=snapshots{isn}.Number;
    stratum=snapshots{isn}.Stratum;
    
    for ist=1:length(stratum)
        strat_name=stratum{ist}.Name;
        transects=stratum{ist}.Transects;
        for itr=1:length(transects)
            
            filenames_cell=transects{itr}.files;
            trans_num=transects{itr}.number;
            fprintf('Processing Snapshot %.0f Stratum %s Transect %.0f\n',snap_num,strat_name,trans_num);
            if ~iscell(filenames_cell)
                filenames_cell={filenames_cell};
            end
            regs=transects{itr}.Regions;
            bot=transects{itr}.Bottom;
            cal_t=transects{itr}.Cal;
            layers_in=[];
            new_lays=0;
            for ifiles=1:length(filenames_cell)
                fileN=fullfile(snapshots{isn}.Folder,filenames_cell{ifiles});
                
                if ~isempty(layers)
                    [idx_lays,found_lay]=layers.find_layer_idx_files_path(fileN);
                else
                    found_lay=0;
                    new_lays=1;
                end
                
                if found_lay>0
                    layers_in=[layers_in layers(idx_lays)];
                    layers(idx_lays)=[];
                    continue;
                else
                    new_lays=1;
                    if exist(fileN,'file')==2
                        new_lay=open_EK60_file_stdalone(fullfile(snapshots{isn}.Folder,filenames_cell{ifiles}),...
                            'PathToMemmap',datapath,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]),'EsOffset',options.Es60_correction);
                        
                         new_lay=open_EK80_file_stdalone(fullfile(snapshots{isn}.Folder,filenames_cell{ifiles}),...
                              'PathToMemmap',datapath,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]));
                        
                        [idx_freq,found]=new_lay.find_freq_idx(options.Frequency);
                        if found==0
                            warning('Cannot file required Frequency in file %s',filenames_cell{ifiles});
                            continue;
                        end
                        
                        layers_in=[layers_in new_lay];
                        clear new_lay;
                    else
                        warning('Cannot Find specified file %s',filenames_cell{ifiles});
                        continue;
                    end
                end
            end
            
            if ~isempty(layers_in)
                layers_out_temp=shuffle_layers(layers_in,'multi_layer',0);
                clear layers_in;
            else
                warning('Could not find any files in this transect...');
                continue;
            end
            
            if new_lays==0 
                for i_lay=1:length(layers_out_temp)
                    layer_new=layers_out_temp(i_lay);
                    u=length(layers)+1;
                    layers(u)=layer_new;
                end
                continue;
            end
            
            
            if length(layers_out_temp)>1
                warning('Non continuous files in Snapshot %.0f Stratum %s Transect %.0f',snap_num,strat_name,trans_num);
            end
            
            for i_lay=1:length(layers_out_temp)
                layer_new=layers_out_temp(i_lay);
                
                if isempty(cal_t)
                    if length(cal)>1
                        for ifcal=1:length(layer_new.Frequencies)
                            if ~isempty(find(cal(:).FREQ==layer_new.Frequencies(ifcal), 1))
                            layer_new.Transceivers(ifcal).apply_cw_cal(cal(cal(:).FREQ==layer_new.Frequencies(ifcal)));
                            end
                        end
                    else
                        layer_new.Transceivers(idx_freq).apply_cw_cal(cal);
                    end
                else
                    layer_new.Transceivers(idx_freq).apply_cw_cal(cal_t);
                end
                
                layer_new.Transceivers(idx_freq).apply_absorption(options.Absorption/1e3);
                
                layer_new.load_echo_logbook();
                
                
                if isfield(bot,'ver')
                    layer_new.load_bot_regs('reg_ver',0);
                end
                
                
                for ire=1:length(regs)
                    if isfield(regs{ire},'ver')    
                        layer_new.load_bot_regs('bot_ver',0);
                    else
                        layer_new.load_bot_regs('bot_ver',0);
                    end
                end
                
                
                
                for ire=1:length(regs)
                    if isfield(regs{ire},'name')
                        switch regs{ire}.name
                            case 'WC'
                                layer_new.Transceivers(idx_freq).rm_region_name('WC');
                                for irewc=1:length(regions_wc)
                                    reg_wc=layer_new.Transceivers(idx_freq).create_WC_region('y_min',regions_wc{irewc}.y_min,...
                                        'Type','Data',...
                                        'Ref',regions_wc{irewc}.Ref,...
                                        'Cell_w',regions_wc{irewc}.Cell_w,...
                                        'Cell_h',regions_wc{irewc}.Cell_h,...
                                        'Cell_w_unit',regions_wc{irewc}.Cell_w_unit,...
                                        'Cell_h_unit',regions_wc{irewc}.Cell_h_unit);
                                    reg_wc.Remove_ST=options.Remove_ST;
                                end
                                layer_new.Transceivers(idx_freq).add_region(reg_wc,'Split',0);
                        end
                    end
                end
                
                
                for ial=1:length(algos)
                    
                    switch algos{ial}.Name
                        case 'SingleTarget'
                            ST=feval(init_func(algos{ial}.Name),layer_new.Transceivers(idx_freq),...
                                'Type','Sv',...
                                'TS_threshold',algos{ial}.Varargin.TS_threshold,...
                                'PLDL',algos{ial}.Varargin.PLDL,...
                                'MinNormPL',algos{ial}.Varargin.MinNormPL,...
                                'MaxNormPL',algos{ial}.Varargin.MaxNormPL,...
                                'MaxBeamComp',algos{ial}.Varargin.MaxBeamComp,...
                                'MaxStdMinAxisAngle',algos{ial}.Varargin.MaxStdMinAxisAngle,...
                                'MaxStdMajAxisAngle',algos{ial}.Varargin.MaxStdMajAxisAngle,...
                                'DataType',layer_new.Transceivers(idx_freq).Mode);
                            layer_new.Transceivers(idx_freq).set_ST(ST);
                            layer_new.Transceivers(idx_freq).Tracks=struct('target_id',{},'target_ping_number',{});
                            
                            
                        case 'TrackTarget'
                            tracks=feval(init_func(algos{ial}.Name),layer_new.Transceivers(idx_freq).ST,...
                                'AlphaMajAxis',algos{ial}.Varargin.AlphaMajAxis,...
                                'AlphaMinAxis',algos{ial}.Varargin.AlphaMinAxis,...
                                'AlphaRange',algos{ial}.Varargin.AlphaRange,...
                                'BetaMajAxis',algos{ial}.Varargin.BetaMajAxis,...
                                'BetaMinAxis',algos{ial}.Varargin.BetaMinAxis,...
                                'BetaRange',algos{ial}.Varargin.BetaRange,...
                                'ExcluDistMajAxis',algos{ial}.Varargin.ExcluDistMajAxis,...
                                'ExcluDistMinAxis',algos{ial}.Varargin.ExcluDistMinAxis,...
                                'ExcluDistRange',algos{ial}.Varargin.ExcluDistRange,...
                                'MaxStdMinorAxisAngle',algos{ial}.Varargin.MaxStdMinorAxisAngle,...
                                'MaxStdMajorAxisAngle',algos{ial}.Varargin.MaxStdMajorAxisAngle,...
                                'MissedPingExpMajAxis',algos{ial}.Varargin.MissedPingExpMajAxis,...
                                'MissedPingExpMinAxis',algos{ial}.Varargin.MissedPingExpMinAxis,...
                                'MissedPingExpRange',algos{ial}.Varargin.MissedPingExpRange,...
                                'WeightMajAxis',algos{ial}.Varargin.WeightMajAxis,...
                                'WeightMinAxis',algos{ial}.Varargin.WeightMinAxis,...
                                'WeightRange',algos{ial}.Varargin.WeightRange,...
                                'WeightTS',algos{ial}.Varargin.WeightTS,...
                                'WeightPingGap',algos{ial}.Varargin.WeightPingGap,...
                                'Min_ST_Track',algos{ial}.Varargin.Min_ST_Track,...
                                'Min_Pings_Track',algos{ial}.Varargin.Min_Pings_Track,...
                                'Max_Gap_Track',algos{ial}.Varargin.Max_Gap_Track);
                            
                            layer_new.Transceivers(idx_freq).Tracks=tracks;
                            
                            if options.Remove_tracks
                                layer_new.Transceivers(idx_freq).create_track_regs('Type','Bad Data');
                            end
                            
                        case 'SchoolDetection'
                            
                            linked_candidates=feval(init_func(algos{ial}.Name),layer_new.Transceivers(idx_freq),...
                                'Type',algos{ial}.Varargin.Type,...
                                'Sv_thr',algos{ial}.Varargin.Sv_thr,...
                                'l_min_can',algos{ial}.Varargin.l_min_can,...
                                'h_min_tot',algos{ial}.Varargin.h_min_tot,...
                                'h_min_can',algos{ial}.Varargin.h_min_can,...
                                'l_min_tot',algos{ial}.Varargin.l_min_tot,...
                                'nb_min_sples',algos{ial}.Varargin.nb_min_sples,...
                                'horz_link_max',algos{ial}.Varargin.horz_link_max,...
                                'vert_link_max',algos{ial}.Varargin.vert_link_max);
                            
                            layer_new.Transceivers(idx_freq).rm_region_name('School');
                            
                            w_unit=options.Vertical_slice_units;
                            switch w_unit
                                case 'pings'
                                    cell_w=ceil(options.Vertical_slice_size/4);
                                case 'meters'
                                    cell_w=options.Vertical_slice_size/4;
                            end
                            
                            h_unit='meters';
                            cell_h=options.Horizontal_slice_size;
                            
                            layer_new.Transceivers(idx_freq).create_regions_from_linked_candidates(linked_candidates,'w_unit',w_unit,'h_unit',h_unit,'cell_w',cell_w,'cell_h',cell_h);
                            
                            if options.Classify_schools==1
                                idx_sch=layer_new.Transceivers(idx_freq).list_regions_name('School');
                                new_figs=layer_new.apply_classification(idx_freq,idx_sch);
                                close(new_figs);
                            end
                    end
                    
                    [idx_algo,~]=layer_new.Transceivers(idx_freq).find_algo_idx(algos{ial}.Name);
                    layer_new.Transceivers(idx_freq).Algo(idx_algo)=algo_cl('Name',algos{ial}.Name,'Varargin',algos{ial}.Varargin);
                    
                end
                u=length(layers)+1;
                layers(u)=layer_new;
            end
            clear layers_out_temp;
        end
        
    end
    
end


if u==0
    layers=[];
end
end




