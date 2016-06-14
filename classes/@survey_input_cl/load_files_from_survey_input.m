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
                        
                        fType=get_ftype(fileN);
                        
                        switch fType
                            case 'EK60'
                                new_lay=open_EK60_file_stdalone(fileN,...
                                    'PathToMemmap',datapath,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]),'EsOffset',options.Es60_correction);
                            case 'EK80'
                                new_lay=open_EK80_file_stdalone(fileN,...
                                    'PathToMemmap',datapath,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]));
                        end
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
                    
                    layer(u).Transceivers(idx_freq).add_algo(algo_cl('Name',algos{ial}.Name,'Varargin',algos{ial}.Varargin));
                    layer(u).Transceivers(idx_freq).apply_algo(algos{ial}.Name);
                    
                    
                    
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




