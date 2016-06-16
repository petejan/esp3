function layers=load_files_from_survey_input(surv_input_obj,varargin)

p = inputParser;

addRequired(p,'surv_input_obj',@(obj) isa(obj,'survey_input_cl'));
addParameter(p,'layers',layer_cl.empty(),@(obj) isa(obj,'layer_cl'));
addParameter(p,'origin','xml',@ischar);
addParameter(p,'cvsroot','',@ischar);
addParameter(p,'PathToMemmap','',@ischar);
addParameter(p,'FieldNames',{},@iscell);

parse(p,surv_input_obj,varargin{:});

datapath=p.Results.PathToMemmap;
infos=surv_input_obj.Infos;
options=surv_input_obj.Options;
regions_wc=surv_input_obj.Regions_WC;
algos=surv_input_obj.Algos;
cal=surv_input_obj.Cal;


snapshots=surv_input_obj.Snapshots;
u=0;
layers=p.Results.layers;

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
                                    'PathToMemmap',datapath,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]),'FieldNames',p.Results.FieldNames);
                            case 'EK80'
                                new_lay=open_EK80_file_stdalone(fileN,...
                                    'PathToMemmap',datapath,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]),'FieldNames',p.Results.FieldNames);
                            case 'dfile'
                                new_lay=read_crest(fileN,'PathToMemmap',datapath,'CVSCheck',0);
                        end
                        [idx_freq,found]=new_lay.find_freq_idx(options.Frequency);
                        if found==0
                            warning('Cannot file required Frequency in file %s',filenames_cell{ifiles});
                            continue;
                        end
                        
                        switch p.Results.origin
                            case 'mbs'
                                new_lay.OriginCrest=transects{itr}.OriginCrest{ifiles};
                                new_lay.CVS_BottomRegions(p.Results.cvsroot);
                                %if ~strcmp(new_lay.Filetype,'CREST')
                                surv=survey_data_cl('Voyage',infos.Voyage,'SurveyName',infos.SurveyName,'Snapshot',snap_num,'Stratum',strat_name,'Transect',trans_num);
                                new_lay.set_survey_data(surv);
                                %end
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
                
                for i_freq=1:length(layer_new.Frequencies)
                    curr_freq=layer_new.Frequencies(i_freq);
                    
                    if ~strcmp(layer_new.Filetype,'CREST')
                        if ~isempty(find(cal(:).FREQ==curr_freq, 1))
                            layer_new.Transceivers(i_freq).apply_cw_cal(cal(cal(:).FREQ==layer_new.Frequencies(i_freq)));
                        else
                            fprintf('No calibration specified for Frequency %.0fkHz. Using file value\n',layer_new.Frequencies(i_freq)/1e3);
                        end
                    end
                    
                    if ~isnan(options.Absorption(options.FrequenciesToLoad==curr_freq))
                        layer_new.Transceivers(i_freq).apply_absorption(options.Absorption(options.FrequenciesToLoad==curr_freq)/1e3);
                    else
                        fprintf('No absorption specified for Frequency %.0fkHz\n. Using file value\n',layer_new.Frequencies(i_freq)/1e3);
                    end
                end
                
                
                switch p.Results.origin
                    case 'xml'
                        
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




