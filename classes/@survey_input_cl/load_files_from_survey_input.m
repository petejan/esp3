function [layers_new,layers_old]=load_files_from_survey_input(surv_input_obj,varargin)

p = inputParser;

addRequired(p,'surv_input_obj',@(obj) isa(obj,'survey_input_cl'));
addParameter(p,'layers',layer_cl.empty(),@(obj) isa(obj,'layer_cl'));
addParameter(p,'origin','xml',@ischar);
addParameter(p,'cvs_root','',@ischar);
addParameter(p,'PathToMemmap','',@ischar);
addParameter(p,'FieldNames',{},@iscell);
addParameter(p,'gui_main_handle',matlab.ui.Figure.empty(),@isfigure);

parse(p,surv_input_obj,varargin{:});

datapath=p.Results.PathToMemmap;
infos=surv_input_obj.Infos;
options=surv_input_obj.Options;
regions_wc=surv_input_obj.Regions_WC;
algos=surv_input_obj.Algos;


snapshots=surv_input_obj.Snapshots;
cal_opt=surv_input_obj.Cal;
layers_old=p.Results.layers;
layers_new=[];
for isn=1:length(snapshots)
    snap_num=snapshots{isn}.Number;
    stratum=snapshots{isn}.Stratum;
    cal_snap=get_cal_node(cal_opt,snapshots{isn});
    fprintf('\nLoading files from %s\n',snapshots{isn}.Folder);
    for ist=1:length(stratum)
        strat_name=stratum{ist}.Name;
        transects=stratum{ist}.Transects;
        cal_strat=get_cal_node(cal_snap,stratum{ist});
        for itr=1:length(transects)
            
            filenames_cell=transects{itr}.files;
            trans_num=transects{itr}.number;
            cal=get_cal_node(cal_strat,transects{itr});
            
            fprintf('Processing Snapshot %.0f Stratum %s Transect %.0f\n',snap_num,strat_name,trans_num);
            if ~iscell(filenames_cell)
                filenames_cell={filenames_cell};
            end
            regs=transects{itr}.Regions;
            %bot=transects{itr}.Bottom;
            layers_in=[];
            fType=cell(1,length(filenames_cell));
            
            for ifiles=1:length(filenames_cell)
                fileN=fullfile(snapshots{isn}.Folder,filenames_cell{ifiles});
                if isfield(transects{itr},'EsError')
                    es_offset=transects{itr}.EsError(ifiles);
                else
                    es_offset=options.Es60_correction;
                end
                
                
                if ~isempty(layers_old)
                    [idx_lays,found_lay]=layers_old.find_layer_idx_files_path(fileN,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]));
                else
                    found_lay=0;
                end
                
                if ~isempty(layers_in)
                    [idx_lay_in,found_lay_in]=layers_in.find_layer_idx_files_path(fileN,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]));
                else
                    found_lay_in=0;
                end
                
                
                if found_lay_in==1
                    fType{ifiles}=layers_in(idx_lay_in(1)).Filetype;
                    continue;
                end
                
                if found_lay>0
                    layers_in=union(layers_in,layers_old(idx_lays(1)));
                    fType{ifiles}=layers_old(idx_lays(1)).Filetype;
                    layers_old(idx_lays(1))=[];
                    continue;
                else
                    if exist(fileN,'file')==2
                        
                        fType{ifiles}=get_ftype(fileN);
                        
                        switch lower(fType{ifiles})
                            case {'ek60','ek80','raw'}
                                %                                 profile on;
                                
                                new_lay=open_raw_file_standalone_v2(fileN,...
                                    'PathToMemmap',datapath,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]),'FieldNames',p.Results.FieldNames,'EsOffset',es_offset);
                                
                                %                                 profile off;
                                %                                 profile viewer
                            case 'asl'
                                new_lay=read_asl(fileN,...
                                    'PathToMemmap',datapath);
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
                                surv=survey_data_cl('Voyage',infos.Voyage,'SurveyName',infos.SurveyName,'Snapshot',snap_num,'Stratum',strat_name,'Transect',trans_num);
                                new_lay.set_survey_data(surv);
                                
                                switch lower(fType{ifiles})
                                    case {'ek60','ek80'}
                                        new_lay.update_echo_logbook_file();
                                        new_lay.write_reg_to_reg_xml();
                                        new_lay.write_bot_to_bot_xml()
                                end
                                
                        end
                        
                        layers_in=union(layers_in,new_lay);
                        clear new_lay;
                    else
                        warning('Cannot Find specified file %s',filenames_cell{ifiles});
                        continue;
                    end
                end
            end
            
            
            if isempty(layers_in)
                warning('Could not find any files in this transect...');
                continue;
            end
            fType_in=cell(1,length(layers_in));
            dates_out=nan(1,length(layers_in));
            for ilay_in=1:length(layers_in)
                fType_in{ilay_in}=layers_in(ilay_in).Filetype;
                dates_out(ilay_in)=layers_in(ilay_in).Transceivers(1).Data.Time(1);
            end
            
            
            switch p.Results.origin
                case 'xml'
                    [fTypes,idx_unique,idx_out]=unique(fType_in);
                    
                    for itype=1:length(fTypes)
                        switch lower(fTypes{itype})
                            case 'asl'
                                max_load_days=1;
                                i_cell=1;
                                new_layers_sorted{i_cell}=[];
                                date_ori=dates_out(1);
                                
                                for i_file=1:length(dates_out)
                                    if i_file>1
                                        if dates_out(i_file)-dates_out(i_file-1)>=1
                                            i_cell=i_cell+1;
                                            new_layers_sorted{i_cell}= layers_in(i_file);
                                            date_ori=dates_out(i_file);
                                            continue;
                                        end
                                    end
                                    
                                    if dates_out(i_file)-date_ori<=max_load_days
                                        new_layers_sorted{i_cell}=[new_layers_sorted{i_cell} layers_in(i_file)];
                                    else
                                        i_cell=i_cell+1;
                                        new_layers_sorted{i_cell}= layers_in(i_file);
                                        date_ori=dates_out(i_file);
                                    end
                                    
                                end
                                
                                disp('Shuffling layers');
                                layers_out_temp=[];
                                
                                for icell=1:length(new_layers_sorted)
                                    layers_out_temp=union(layers_out_temp,shuffle_layers(new_layers_sorted{icell},'multi_layer',-1));
                                end
                                
                                clear layers_in;
                                clear new_layers_sorted;
                                
                            otherwise
                                
                                layers_out_temp=shuffle_layers(layers_in(idx_unique(itype)==idx_out),'multi_layer',0);
                                clear layers_in;
                                
                        end
                    end
                case 'mbs'
                    layers_out_temp=layers_in;
                    clear layers_in;
            end
            
            if length(layers_out_temp)>1
                warning('Non continuous files in Snapshot %.0f Stratum %s Transect %.0f',snap_num,strat_name,trans_num);
            end
            
            i_cal=0;
            for i_lay=1:length(layers_out_temp)
                layer_new=layers_out_temp(i_lay);
                [idx_freq,~]=layer_new.find_freq_idx(options.Frequency);
                i_cal=i_cal+length(layer_new.Filename);
                if iscell(cal)
                    cal_curr=cal{i_cal};
                else
                    cal_curr=cal;
                end
                for i_freq=1:length(layer_new.Frequencies)
                    curr_freq=layer_new.Frequencies(i_freq);
                    
                    switch lower(layer_new.Filetype)
                        case {'ek60','ek80'}
                            if any([cal_curr(:).FREQ]==curr_freq)
                                layer_new.Transceivers(i_freq).apply_cw_cal(cal_curr([cal_curr(:).FREQ]==layer_new.Frequencies(i_freq)));
                            else
                                fprintf('No calibration specified for Frequency %.0fkHz. Using file value\n',layer_new.Frequencies(i_freq)/1e3);
                            end
                    end
                    
                    if ~isnan(options.Absorption(options.FrequenciesToLoad==curr_freq))
                        layer_new.Transceivers(i_freq).apply_absorption(options.Absorption(options.FrequenciesToLoad==curr_freq)/1e3);
                    else
                        fprintf('No absorption specified for Frequency %.0fkHz. Using file value\n',layer_new.Frequencies(i_freq)/1e3);
                    end
                    
                    if ~isnan(options.Soundspeed)
                        layer_new.apply_soundspeed(options.Soundspeed);
                    end
                end
                
                
                switch p.Results.origin
                    case 'xml'
                        switch lower(layer_new.Filetype)
                            case {'ek60','ek80'}
                                layer_new.load_echo_logbook();
                            case 'asl'
                                surv=survey_data_cl('Voyage',infos.Voyage,'SurveyName',infos.SurveyName,'Snapshot',snap_num,'Stratum',strat_name,'Transect',trans_num);
                                layer_new.set_survey_data(surv);
                        end
                        layer_new.load_bot_regs('reg_ver',0,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]));
                        layer_new.load_bot_regs('bot_ver',0,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]));
                end
                
                
                for ire=1:length(regs)
                    if isfield(regs{ire},'name')
                        switch regs{ire}.name
                            case 'WC'
                                layer_new.Transceivers(idx_freq).rm_region_name('WC');
                                for irewc=1:length(regions_wc)
                                    if isfield(regions_wc{irewc},'y_max')
                                        y_max=regions_wc{irewc}.y_max;
                                    else
                                        y_max=inf;
                                    end
                                    reg_wc=layer_new.Transceivers(idx_freq).create_WC_region(...
                                        'y_max',y_max,...
                                        'y_min',regions_wc{irewc}.y_min,...
                                        'Type','Data',...
                                        'Ref',regions_wc{irewc}.Ref,...
                                        'Cell_w',regions_wc{irewc}.Cell_w,...
                                        'Cell_h',regions_wc{irewc}.Cell_h,...
                                        'Cell_w_unit',regions_wc{irewc}.Cell_w_unit,...
                                        'Cell_h_unit',regions_wc{irewc}.Cell_h_unit);
                                    reg_wc.Remove_ST=options.Remove_ST;
                                    layer_new.Transceivers(idx_freq).add_region(reg_wc,'Split',0);
                                end
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
                
                layers_new=union(layers_new,layer_new);
                
                if ~isempty(p.Results.gui_main_handle)
                    if isappdata(p.Results.gui_main_handle,'Layers')&&isappdata(p.Results.gui_main_handle,'Layer')
                        setappdata(p.Results.gui_main_handle,'Layer',layer_new);
                        setappdata(p.Results.gui_main_handle,'Layers',[layers_old layers_new]);
                        try
                            loadEcho(p.Results.gui_main_handle);
                        catch err
                            disp(err.MEssage);
                        end
                    end
                end
            end
            clear layers_out_temp;
        end
        
    end
    
end


end


function cal=get_cal_node(cal_ori,node)
cal=cal_ori;
if ~isempty(node.Cal)
    cal_temp_cell=node.Cal;
    if ~iscell(cal_temp_cell)
        cal_temp_cell={cal_temp_cell};
    end
    cal=cell(1,length(cal_temp_cell));
    
    for icell=1:length(cal_temp_cell)
        call_out_temp=[];
        for ical=1:length(cal_temp_cell{icell})
            cal_temp=cal_temp_cell{icell};
            if ~isempty(cal_ori)
                call_out_temp=cal_ori;
                if any([call_out_temp(:).FREQ]==cal_temp(ical).FREQ)
                    call_out_temp([call_out_temp(:).FREQ]==cal_temp(ical).FREQ)=cal_temp(ical);
                else
                    call_out_temp(length(call_out_temp)+1)=cal_temp(ical);
                end
            else
                call_out_temp=cal_temp;
            end
        end
        cal{icell}=call_out_temp;
    end
    
    if length(cal)==1
        cal=cal{1};
    end
end
end

