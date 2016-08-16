function layers=load_files_from_survey_input(surv_input_obj,varargin)

p = inputParser;

addRequired(p,'surv_input_obj',@(obj) isa(obj,'survey_input_cl'));
addParameter(p,'layers',layer_cl.empty(),@(obj) isa(obj,'layer_cl'));
addParameter(p,'origin','xml',@ischar);
addParameter(p,'cvs_root','',@ischar);
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

            for ifiles=1:length(filenames_cell)
                fileN=fullfile(snapshots{isn}.Folder,filenames_cell{ifiles});
                
                if isfield(transects{itr},'EsError')
                    es_offset=transects{itr}.EsError(ifiles);
                else
                    es_offset=options.Es60_correction;
                end
                if isfield(transects{itr},'Cal')%
                    cal_temp=transects{itr}.Cal{ifiles};
                    cal_temp.FREQ=options.Frequency;
                    
                    if ~isempty(find([cal(:).FREQ]==options.Frequency, 1))
                          cal([cal(:).FREQ]==options.Frequency)=cal_temp;
                    else
                        cal(length(cal)+1)=cal_temp;
                    end
                else
                    cal=surv_input_obj.Cal;
                end
                
                if ~isempty(layers)
                    [idx_lays,found_lay]=layers.find_layer_idx_files_path(fileN,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]));    
                else
                    found_lay=0; 
                end
                
                if ~isempty(layers_in)
                    [~,found_lay_in]=layers_in.find_layer_idx_files_path(fileN,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]));
                else
                    found_lay_in=0;
                end
                
                
                if found_lay_in==1
                    continue;
                end
                
                if found_lay>0
                    layers_in=[layers_in layers(idx_lays(1))];
                    layers(idx_lays(1))=[];
                    continue;
                else
                    if exist(fileN,'file')==2
                        
                        fType=get_ftype(fileN);
                        
                        switch fType
                            case {'EK60','EK80'}
%                                 profile on;

                                new_lay=open_raw_file_standalone_v2(fileN,...
                                    'PathToMemmap',datapath,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]),'FieldNames',p.Results.FieldNames,'EsOffset',es_offset);
%                                  new_lay=open_raw_file_standalone(fileN,...
%                                     'PathToMemmap',datapath,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]),'FieldNames',p.Results.FieldNames,'EsOffset',es_offset);
% %                             
%                                 profile off;
%                                 profile viewer
                           case 'dfile'
                                new_lay=read_crest(fileN,'PathToMemmap',datapath,'CVSCheck',0);
                        end
                       [~,found]=new_lay.find_freq_idx(options.Frequency);
                        if found==0
                            warning('Cannot file required Frequency in file %s',filenames_cell{ifiles});
                            continue;
                        end
                        
                        switch p.Results.origin
                            case 'mbs'
                                new_lay.OriginCrest=transects{itr}.OriginCrest{ifiles};
                                new_lay.CVS_BottomRegions(p.Results.cvs_root);
                                %if ~strcmp(new_lay.Filetype,'CREST')
                                surv=survey_data_cl('Voyage',infos.Voyage,'SurveyName',infos.SurveyName,'Snapshot',snap_num,'Stratum',strat_name,'Transect',trans_num);
                                new_lay.set_survey_data(surv);
                                %end
                                switch fType
                                    case {'EK60','EK80'}
                                        new_lay.update_echo_logbook_file();
                                end
                                
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
            

            if length(layers_out_temp)>1
                warning('Non continuous files in Snapshot %.0f Stratum %s Transect %.0f',snap_num,strat_name,trans_num);
            end
            
            for i_lay=1:length(layers_out_temp)
                layer_new=layers_out_temp(i_lay);
                [idx_freq,~]=layer_new.find_freq_idx(options.Frequency);
                
                for i_freq=1:length(layer_new.Frequencies)
                    curr_freq=layer_new.Frequencies(i_freq);
                    
                    if ~strcmp(layer_new.Filetype,'CREST')
                        if ~isempty(find([cal(:).FREQ]==curr_freq, 1))
                            layer_new.Transceivers(i_freq).apply_cw_cal(cal([cal(:).FREQ]==layer_new.Frequencies(i_freq)));
                        else
                            fprintf('No calibration specified for Frequency %.0fkHz. Using file value\n',layer_new.Frequencies(i_freq)/1e3);
                        end
                    end
                    
                    if ~isnan(options.Absorption(options.FrequenciesToLoad==curr_freq))
                        layer_new.Transceivers(i_freq).apply_absorption(options.Absorption(options.FrequenciesToLoad==curr_freq)/1e3);
                    else
                        fprintf('No absorption specified for Frequency %.0fkHz. Using file value\n',layer_new.Frequencies(i_freq)/1e3);
                    end
                end
                
                
                switch p.Results.origin
                    case 'xml'
                        
                        layer_new.load_echo_logbook();
                        
                        if isfield(bot,'ver')
                            layer_new.load_bot_regs('reg_ver',0,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]));
                        end
                        
                        if ~isempty(regs)
                            for ire=1:length(regs)
                                if isfield(regs{ire},'ver')
                                    layer_new.load_bot_regs('bot_ver',0,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]));
                                end
                            end
                        else
                            for idx_freq_reg=1:length(layer_new.Transceivers)
                                layer_new.Transceivers(idx_freq_reg).rm_all_region();
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
                    if isempty(algos{ial}.Varargin.Frequencies)
                        layer_new.Transceivers(idx_freq).add_algo(algo_cl('Name',algos{ial}.Name,'Varargin',algos{ial}.Varargin));
                        layer_new.Transceivers(idx_freq).apply_algo(algos{ial}.Name);
                    else
                        for i_freq_al=1:length(algos{ial}.Varargin.Frequencies)
                           [idx_freq_al,found_freq_al]=layer_new.find_freq_idx(algos{ial}.Varargin.Frequencies(i_freq_al)); 
                           if found_freq_al>0
                               layer_new.Transceivers(idx_freq_al).add_algo(algo_cl('Name',algos{ial}.Name,'Varargin',algos{ial}.Varargin));
                               layer_new.Transceivers(idx_freq_al).apply_algo(algos{ial}.Name);
                           else
                                fprintf('Could not find Frequency %.0fkHz. Algo %s not applied on it\n',algos{ial}.Varargin.Frequencies(i_freq_al)/1e3,algos{ial}.Name);
                           end
                        end
                    end
                end
                
                if options.ClassifySchool>0
                    [idx_120,found_120]=find_freq_idx(layer_new,120000);
                    if found_120>0
                        idx_school_120 = layer_new.Transceivers(idx_120).list_regions_name('School');
                        if ~isempty(idx_school_120)
                            if idx_freq~=idx_120
                                layer_new.copy_region_across(idx_120,layer_new.Transceivers(idx_120).Regions,idx_freq);
                                layer_new.Transceivers(idx_120).rm_region_name('School')
                                new_regions=layer_new.Transceivers(idx_freq).Regions.merge_regions();
                                layer_new.Transceivers(idx_freq).rm_all_region();
                                layer_new.Transceivers(idx_freq).add_region(new_regions,'IDs',1:length(new_regions));
                            end
                        end
                    end
                    
                    idx_schools=layer_new.Transceivers(idx_freq).list_regions_name('School');
                    if ~isempty(idx_schools)
                        layer_new.apply_classification(idx_freq,idx_schools,0);
                    end
                end
                
                if options.Remove_tracks
                    layer_new.Transceivers(idx_freq).create_track_regs('Type','Bad Data');
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




