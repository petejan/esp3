function layers=load_files_from_survey_input(surv_input_obj,varargin)

p = inputParser;

addRequired(p,'surv_input_obj',@(obj) isa(obj,'survey_input_cl'));

addParameter(p,'PathToMemmap','',@ischar)

parse(p,surv_input_obj,varargin{:});


datapath=p.Results.PathToMemmap;
infos=surv_input_obj.Infos;
options=surv_input_obj.Options;
regions_wc=surv_input_obj.Regions_WC;
algos=surv_input_obj.Algos;
cal=surv_input_obj.Cal;


snapshots=surv_input_obj.Snapshots;
u=0;
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
            
            for ifiles=1:length(filenames_cell)
                fileN=fullfile(snapshots{isn}.Folder,filenames_cell{ifiles});
                if exist(fileN,'file')==2
                    new_lay=open_EK60_file_stdalone(fullfile(snapshots{isn}.Folder,filenames_cell{ifiles}),...
                        'PathToMemmap',datapath,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]),'EsOffset',options.Es60_correction);
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
            
            if ~isempty(layers_in)
                layers_out_temp=shuffle_layers(layers_in,'multi_layer',0);
                clear layers_in;
            else
                warning('Could not find any files in this transect...');
                layers_out_temp=[];
            end
            
            
            if length(layers_out_temp)>1
                warning('Non continuous files in Snapshot %.0f Stratum %s Transect %.0f',snap_num,strat_name,trans_num);
            end
            
            for i_lay=1:length(layers_out_temp)
                layer_new=layers_out_temp(i_lay);
                
                if isempty(cal_t)
                    layer_new.Transceivers(idx_freq).apply_cw_cal(cal);
                else
                    layer_new.Transceivers(idx_freq).apply_cw_cal(cal_t);
                end
                layer_new.Transceivers(idx_freq).apply_absorption(options.Absorption/1e3);
                
                surv=survey_data_cl('Voyage',infos.Voyage,'SurveyName',infos.Title,'Snapshot',snap_num,'Stratum',strat_name,'Transect',trans_num);
                layer_new.set_survey_data(surv);
                
                if isfield(bot,'file')
                    if exist(fullfile(snapshots{isn}.Folder,bot.file),'file')>0
                        layer_new.Transceivers(idx_freq).setBottom_from_evl(fullfile(snapshots{isn}.Folder,bot.file));
                    else
                        warning('Cannot find bottom for file %s',layer_new.Filename{1});
                    end
                    layer_new.save_bot_regs('save_regs',0);
                end
                
                
                if isfield(bot,'ver')
                    layer_new.load_bot_regs('reg_ver',0);
                end
                
                
                for ire=1:length(regs)
                    if isfield(regs{ire},'ver')
                        if isfield(regs{ire},'IDs')
                            if ischar(regs{ire}.IDs)
                                IDs=str2double(strsplit(regs{ire}.IDs,';'));
                            else
                                IDs=regs{ire}.IDs;
                            end
                            layer_new.load_bot_regs('bot_ver',0,'IDs',IDs);
                        else
                            layer_new.load_bot_regs('bot_ver',0);
                        end
                    end
                end
                
                nb_reg_out=0;
                for ire=1:length(regs)
                    if isfield(regs{ire},'file')
                        nb_reg_out=nb_reg_out+1;
                        if  exist(fullfile(snapshots{isn}.Folder,regs{ire}.file),'file')>0
                            new_reg=create_regions_from_evr(fullfile(snapshots{isn}.Folder,regs{ire}.file),layer_new.Transceivers(idx_freq).Data.get_range(),layer_new.Transceivers(idx_freq).Data.Time);
                            if isempty(new_reg)
                                continue;
                            end
                            for iur=1:length(new_reg)
                                new_reg(iur).Remove_ST=options.Remove_ST;
                            end
                            layer_new.Transceivers(idx_freq).add_region(new_reg);
                        else
                            warning('Cannot find region for file %s',layer_new.Filename{:});
                        end
                    end
                end
                
                if nb_reg_out>=1
                    layer_new.save_bot_regs('save_bot',0);
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
                    
                    
                end
                
                [idx_algo,~]=layer_new.Transceivers(idx_freq).find_algo_idx(algos{ial}.Name);
                layer_new.Transceivers(idx_freq).Algo(idx_algo)=algo_cl('Name',algos{ial}.Name,'Varargin',algos{ial}.Varargin);
                
            end
            u=u+1;
            layers(u)=layer_new;
        end
        clear layers_out_temp;
    end
    
end


if u==0
    layers=[];
end
end




