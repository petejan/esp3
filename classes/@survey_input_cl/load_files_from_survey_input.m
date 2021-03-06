%% load_files_from_survey_input.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |surv_input_obj|: TODO: write description and info on variable
% * |layers|: TODO: write description and info on variable
% * |origin|: TODO: write description and info on variable
% * |cvs_root|: TODO: write description and info on variable
% * |PathToMemmap|: TODO: write description and info on variable
% * |FieldNames|: TODO: write description and info on variable
% * |gui_main_handle|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |layers_new|: TODO: write description and info on variable
% * |layers_old|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-07-05: started code cleanup and comment (Alex Schimel)
% * 2015-12-18: first version (Yoann Ladroit).
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function [layers_new,layers_old] = load_files_from_survey_input(surv_input_obj,varargin)

%% Managing input variables

% input parser
p = inputParser;

% add parameters
addRequired(p,'surv_input_obj',@(obj) isa(obj,'survey_input_cl'));
addParameter(p,'layers',layer_cl.empty(),@(obj) isa(obj,'layer_cl'));
addParameter(p,'origin','xml',@ischar);
addParameter(p,'cvs_root','',@ischar);
addParameter(p,'PathToMemmap','',@ischar);
addParameter(p,'FieldNames',{},@iscell);
addParameter(p,'gui_main_handle',matlab.ui.Figure.empty(),@ishandle);

% parse
parse(p,surv_input_obj,varargin{:});

% get results
layers_old      = p.Results.layers;
origin          = p.Results.origin;
cvs_root        = p.Results.cvs_root;
datapath        = p.Results.PathToMemmap;
FieldNames      = p.Results.FieldNames;
gui_main_handle = p.Results.gui_main_handle;

%%

if ~isempty(gui_main_handle)
    load_bar_comp = getappdata(gui_main_handle,'Loading_bar');
else
    load_bar_comp = [];
end

infos      = surv_input_obj.Infos;
regions_wc = surv_input_obj.Regions_WC;
algos      = surv_input_obj.Algos;
snapshots  = surv_input_obj.Snapshots;
cal_opt    = surv_input_obj.Cal;
[~,~,trans_tot,~]=surv_input_obj.merge_survey_input_for_integration();
nb_trans_tot=numel(trans_tot);
layers_new = [];
itr_tot=0;
for isn = 1:length(snapshots)
    snap_num = snapshots{isn}.Number;
    stratum = snapshots{isn}.Stratum;
    
    if isfield(snapshots{isn},'Cal_rev')
        svCorr = CVS_CalRevs(cvs_root,'CalRev',snapshots{isn}.Cal_rev);
    else
        svCorr = 1;
    end
    
    if isfield(snapshots{isn},'Options')
        options = snapshots{isn}.Options;
    else
        options = surv_input_obj.Options;
    end
    
    try
        cal_snap = get_cal_node(cal_opt,snapshots{isn});
    catch
        cal_snap = cal_opt;
    end
    fprintf('\nLoading files from %s\n',snapshots{isn}.Folder);
    for ist = 1:length(stratum)
        strat_name = stratum{ist}.Name;
        transects = stratum{ist}.Transects;
        cal_strat = get_cal_node(cal_snap,stratum{ist});
        if isfield(stratum{ist},'Options')
            options = stratum{ist}.Options;
        end
        
        %         strat_type = stratum{ist}.Type;
        %         strat_radius = stratum{ist}.radius;
        
        for itr = 1:length(transects)
            
            try
                filenames_cell = transects{itr}.files;
                trans_num = transects{itr}.number;
                try
                    cal = get_cal_node(cal_strat,transects{itr});
                catch
                    cal = cal_strat;
                end
                show_status_bar(gui_main_handle);
                disp_str=sprintf('Loading Snapshot %.0f Stratum %s Transect %.0f\n',snap_num,strat_name,trans_num);
                disp(disp_str);
                
                if ~iscell(filenames_cell)
                    filenames_cell = {filenames_cell};
                end
                
                regs = transects{itr}.Regions;
                reg_ver = 0;
                
                for ireg = 1:length(regs)
                    if isfield(regs{ireg},'ver')
                        reg_ver = nanmax(reg_ver,regs{ireg}.ver);
                    end
                end
                
                bot = transects{itr}.Bottom;
                bot_ver = 0;
                
                if isfield(bot,'ver')
                    bot_ver = nanmax(bot_ver,bot.ver);
                end
                
                layers_in = [];
                fType = cell(1,length(filenames_cell));
                already_proc = zeros(1,length(filenames_cell));
                
                for ifiles = 1:length(filenames_cell)
                    
                    fileN = fullfile(snapshots{isn}.Folder,filenames_cell{ifiles});
                    
                    if isfield(transects{itr},'Es60_correction')
                        es_offset = transects{itr}.Es60_correction(ifiles);
                    else
                        es_offset = options.Es60_correction;
                    end
                    
                    if ~isempty(layers_old)
                        [idx_lays,found_lay] = layers_old.find_layer_idx_files_path(fileN,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]));
                    else
                        found_lay = 0;
                    end
                    
                    if ~isempty(layers_new)
                        [idx_lay_new,found_lay_new] = layers_new.find_layer_idx_files_path(fileN,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]));
                    else
                        found_lay_new = 0;
                    end
                    
                    if ~isempty(layers_in)
                        [idx_lay_in,found_lay_in] = layers_in.find_layer_idx_files_path(fileN,'Frequencies',unique([options.Frequency options.FrequenciesToLoad]));
                    else
                        found_lay_in = 0;
                    end
                    
                    if found_lay_in == 1
                        fType{ifiles} = layers_in(idx_lay_in(1)).Filetype;
                        continue;
                    end
                    
                    if found_lay_new == 1
                        fType{ifiles} = layers_new(idx_lay_new(1)).Filetype;
                        already_proc(ifiles) = 1;
                        continue;
                    end
                    
                    if found_lay>0
                        layers_in = union(layers_in,layers_old(idx_lays(1)));
                        fType{ifiles} = layers_old(idx_lays(1)).Filetype;
                        layers_old(idx_lays(1)) = [];
                        continue;
                    else
                        if exist(fileN,'file') == 2
                            
                            fType{ifiles} = get_ftype(fileN);
                            if strcmp(fType{ifiles},'dfile')
                                dfile=1;
                            else
                                dfile=0;
                            end
                            
                            [new_lay,~]=open_file_standalone(fileN,fType{ifiles},...
                                'PathToMemmap',datapath,...
                                'Frequencies',unique([options.Frequency options.FrequenciesToLoad]),...
                                'EsOffset',es_offset,...
                                'load_bar_comp',load_bar_comp,...
                                'LoadEKbot',1,'CVSCheck',0,...
                                'force_open',1,...
                                'CVSroot',cvs_root,'dfile',dfile,'CVSCheck',0,'SvCorr',svCorr);
                            
                            switch lower(fType{ifiles})
                                case {'ek60','ek80','raw'}
                                    %new_lay.add_gps_data_to_db();
                                    new_lay.add_ping_data_to_db();
                                case {'asl' 'dfile'}
                                    
                                otherwise
                                    fprintf('Unrecognized file type for file %s',fileN);
                                    continue
                            end
                            [~,found] = new_lay.find_freq_idx(options.Frequency);
                            if found == 0
                                warning('Cannot file required Frequency in file %s',filenames_cell{ifiles});
                                continue;
                            end
                            
                            switch origin
                                case 'mbs'
                                    new_lay.OriginCrest = transects{itr}.OriginCrest{ifiles};
                                    new_lay.CVS_BottomRegions(cvs_root);
                                    surv = survey_data_cl('Voyage',infos.Voyage,'SurveyName',infos.SurveyName,...
                                        'Snapshot',snap_num,'Stratum',strat_name,'Transect',trans_num);
                                    new_lay.set_survey_data(surv);
                                    
                                    switch lower(fType{ifiles})
                                        case {'ek60','ek80','raw'}
                                            new_lay.update_echo_logbook_dbfile();
                                            new_lay.write_reg_to_reg_xml();
                                            new_lay.write_bot_to_bot_xml()
                                    end
                            end
                            
                            layers_in = union(layers_in,new_lay);
                            clear new_lay;
                            
                        else
                            
                            warning('Cannot Find specified file %s',filenames_cell{ifiles});
                            continue;
                            
                        end
                    end
                end
                
                if all(already_proc)
                    continue;
                end
                
                if isempty(layers_in)
                    warning('Could not find any files in this transect...');
                    continue;
                end
                
                fType_in = cell(1,length(layers_in));
                dates_out = nan(1,length(layers_in));
                for ilay_in = 1:length(layers_in)
                    fType_in{ilay_in} = layers_in(ilay_in).Filetype;
                    dates_out(ilay_in) = layers_in(ilay_in).Transceivers(1).Time(1);
                end
                
                switch origin
                    case 'xml'
                        
                        [fTypes,idx_unique,idx_out] = unique(fType_in);
                        
                        for itype = 1:length(fTypes)
                            
                            switch lower(fTypes{itype})
                                
                                case 'asl'
                                    
                                    max_load_days = 1;
                                    i_cell = 1;
                                    new_layers_sorted{i_cell} = [];
                                    date_ori = dates_out(1);
                                    
                                    for i_file = 1:length(dates_out)
                                        if i_file>1
                                            if dates_out(i_file)-dates_out(i_file-1) >= 1
                                                i_cell = i_cell+1;
                                                new_layers_sorted{i_cell} = layers_in(i_file);
                                                date_ori = dates_out(i_file);
                                                continue;
                                            end
                                        end
                                        
                                        if dates_out(i_file)-date_ori <= max_load_days
                                            new_layers_sorted{i_cell} = [new_layers_sorted{i_cell} layers_in(i_file)];
                                        else
                                            i_cell = i_cell+1;
                                            new_layers_sorted{i_cell} = layers_in(i_file);
                                            date_ori = dates_out(i_file);
                                        end
                                        
                                    end
                                    
                                    disp('Shuffling layers');
                                    layers_out_temp = [];
                                    
                                    for icell = 1:length(new_layers_sorted)
                                        layers_out_temp = union(layers_out_temp,shuffle_layers(new_layers_sorted{icell},'multi_layer',-1));
                                    end
                                    
                                    clear layers_in;
                                    clear new_layers_sorted;
                                    
                                otherwise
                                    
                                    layers_out_temp = shuffle_layers(layers_in(idx_unique(itype) == idx_out),'multi_layer',0);
                                    clear layers_in;
                                    
                            end
                        end
                        
                    case 'mbs'
                        layers_out_temp = layers_in;
                        clear layers_in;
                end
                
                if length(layers_out_temp)>1
                    warning('Non continuous files in Snapshot %.0f Stratum %s Transect %.0f',snap_num,strat_name,trans_num);
                end
                
                i_cal = 0;
                for i_lay = 1:length(layers_out_temp)
                    layer_new = layers_out_temp(i_lay);
                    [cal_path,~,~]=fileparts(layer_new.Filename{1});
                    cal_file=fullfile(cal_path,'cal_echo.csv');
                    if isfile(cal_file)
                        cal_f=csv2struct(cal_file);
                    else
                        cal_f=[];
                    end
                    trans_obj_primary= layer_new.get_trans(options.Frequency);
                    
                    i_cal = i_cal+length(layer_new.Filename);
                    if iscell(cal)
                        cal_curr = cal{i_cal};
                    else
                        cal_curr = cal;
                    end
                    for i = 1:length(options.FrequenciesToLoad)
                        curr_freq = options.FrequenciesToLoad(i);
                        [i_freq,found]=layer_new.find_freq_idx(options.FrequenciesToLoad(i));
                        if found==0
                            warning('Could not find %.0f kHz',curr_freq/1e3);
                            continue;
                        end
                        switch origin
                            case 'xml'
                                switch lower(layer_new.Filetype)
                                    case {'ek60','ek80'}
                                        layer_new.load_echo_logbook_db();
                                    case 'asl'
                                        surv = survey_data_cl('Voyage',infos.Voyage,'SurveyName',infos.SurveyName,'Snapshot',snap_num,'Stratum',strat_name,'Transect',trans_num);
                                        layer_new.set_survey_data(surv);
                                end
                                layer_new.load_bot_regs('Frequencies',unique([options.Frequency options.FrequenciesToLoad]),'bot_ver',bot_ver,'reg_ver',reg_ver);
                                layer_new.add_lines_from_line_xml();
                        end
                        
                        if ~isnan(options.Soundspeed)
                            layer_new.apply_soundspeed(options.Soundspeed);
                        end
                        nocal=1;
                        switch lower(layer_new.Filetype)
                            case {'ek60','ek80'}
                                idx_cal=[cal_curr(:).FREQ] == curr_freq;
                                if any(idx_cal)
                                    if all(isfield(cal_curr(idx_cal),{'G0' 'SACORRECT'}))
                                        nocal=0;
                                        cal_t=cal_curr([cal_curr(:).FREQ] == layer_new.Frequencies(i_freq));
                                        
                                        
                                    end
                                end
                                if nocal==1&&all(isfield(cal_f,{'F' 'G0' 'SACORRECT'}))
                                    try
                                        idx_cal=cal_f.F == curr_freq;
                                        if any(idx_cal)
                                            cal_t=struct('G0',cal_f.G0(idx_cal),'SACORRECT',cal_f.SACORRECT(idx_cal));
                                            nocal=0;
                                        end
                                    catch
                                        nocal=1;
                                    end
                                end
                                if nocal>0
                                    fprintf('No calibration specified for Frequency %.0f kHz. Using file value\n',layer_new.Frequencies(i_freq)/1e3);
                                    
                                else
                                    layer_new.Transceivers(i_freq).apply_cw_cal(cal_t);
                                    
                                end
                                
                            case {'dfile' 'asl'}
                                
                        end
                        
                        noabs=1;
                        if ~isnan(options.Absorption(options.FrequenciesToLoad == curr_freq))
                            alpha=options.Absorption(options.FrequenciesToLoad == curr_freq);
                            noabs=0;
                        elseif  all(isfield(cal_f,{'alpha' 'F'}))
                            
                            try
                                idx_abs=cal_f.F == curr_freq;
                                if any(idx_cal)
                                    alpha=cal_f.alpha(idx_abs);
                                    noabs=0;
                                end
                            catch
                                noabs=1;
                            end
                            
                        end
                        if noabs>0
                            fprintf('No absorption specified for Frequency %.0f kHz. Using file value\n',layer_new.Frequencies(i_freq)/1e3);
                        else
                            layer_new.Transceivers(i_freq).apply_absorption(alpha/1e3);
                        end
                        
                        if options.Motion_correction
                            create_motion_comp_subdata(layer_new,i_freq,0);
                        end
                        
                    end
                    
                    
                    
                    for ial = 1:length(algos)
                        fprintf('Applying %s\n',algos{ial}.Name);
                        if isempty(algos{ial}.Varargin.Frequencies)
                            
                            trans_obj_primary.add_algo(algo_cl('Name',algos{ial}.Name,'Varargin',algos{ial}.Varargin));
                            trans_obj_primary.apply_algo(algos{ial}.Name,'load_bar_comp',load_bar_comp);
                        else
                            for i_freq_al = 1:length(algos{ial}.Varargin.Frequencies)
                                [idx_freq_al,found_freq_al] = layer_new.find_freq_idx(algos{ial}.Varargin.Frequencies(i_freq_al));
                                if found_freq_al>0
                                    layer_new.Transceivers(idx_freq_al).add_algo(algo_cl('Name',algos{ial}.Name,'Varargin',algos{ial}.Varargin));
                                    layer_new.Transceivers(idx_freq_al).apply_algo(algos{ial}.Name,'load_bar_comp',load_bar_comp);
                                else
                                    fprintf('Could not find Frequency %.0f kHz. Algo %s not applied on it\n',algos{ial}.Varargin.Frequencies(i_freq_al)/1e3,algos{ial}.Name);
                                end
                            end
                        end
                    end
                    
                    if options.SaveBot>0
                        layer_new.write_bot_to_bot_xml();
                    end
                    
                    for ire = 1:length(regs)
                        if isfield(regs{ire},'name')
                            switch regs{ire}.name
                                case 'WC'
                                    trans_obj_primary.rm_region_name('WC');
                                    for irewc = 1:length(regions_wc)
                                        if isfield(regions_wc{irewc},'y_max')
                                            y_max = regions_wc{irewc}.y_max;
                                        else
                                            y_max = inf;
                                        end
                                        if isfield(regions_wc{irewc},'t_min')
                                            t_min = datenum(regions_wc{irewc}.t_min,'yyyy/mm/dd HH:MM:SS');
                                        else
                                            t_min = 0;
                                        end
                                        
                                        if isfield(regions_wc{irewc},'t_max')
                                            t_max = datenum(regions_wc{irewc}.t_max,'yyyy/mm/dd HH:MM:SS');
                                        else
                                            t_max = Inf;
                                        end
                                        
                                        reg_wc = trans_obj_primary.create_WC_region(...
                                            'y_max',y_max,...
                                            'y_min',regions_wc{irewc}.y_min,...
                                            't_min',t_min,...
                                            't_max',t_max,...
                                            'Type','Data',...
                                            'Ref',regions_wc{irewc}.Ref,...
                                            'Cell_w',regions_wc{irewc}.Cell_w,...
                                            'Cell_h',regions_wc{irewc}.Cell_h,...
                                            'Cell_w_unit',regions_wc{irewc}.Cell_w_unit,...
                                            'Cell_h_unit',regions_wc{irewc}.Cell_h_unit);
                                        
                                        
                                        trans_obj_primary.add_region(reg_wc,'Split',0);
                                    end
                            end
                        end
                    end
                    
                    for ireg=1:length(trans_obj_primary.Regions)
                        trans_obj_primary.Regions(ireg).Remove_ST=options.Remove_ST;
                    end
                    
                    if options.ClassifySchool>0
                        
                        layer_new.apply_classification('primary_freq',options.Frequency,'classification_file',options.ClassificationFile,'denoised',options.Denoised);
                    end
                    
                    if options.Remove_tracks
                        trans_obj_primary.create_track_regs('Type','Bad Data');
                    end
                    if options.SaveReg>0
                        layer_new.write_reg_to_reg_xml();
                    end
                    
                    layers_new = union(layers_new,layer_new);
                    
                    if ~isempty(gui_main_handle)
                        if isappdata(gui_main_handle,'Layers')&&isappdata(gui_main_handle,'Layer')
                            setappdata(gui_main_handle,'Layer',layer_new);
                            setappdata(gui_main_handle,'Layers',[layers_old layers_new]);
                            
                            try
                                loadEcho(gui_main_handle);
                            catch err
                                disp(err.message);
                            end
                            
                        end
                    end
                    
                end
                clear layers_out_temp;
                
            catch err

                warning('Error openning file for Snapshot %.0f Stratum %s Transect %d\n',snap_num,strat_name,trans_num);
                [~,f_temp,e_temp]=fileparts(err.stack(1).file);
                fprintf('Error in file %s, line %d\n',[f_temp e_temp],err.stack(1).line);
                disp(err.message);
                
            end
            itr_tot=itr_tot+1;
            if ~isempty(load_bar_comp)
                set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',nb_trans_tot,'Value',itr_tot);
                load_bar_comp.status_bar.setText(disp_str);
            end
        end
    end
    
end
hide_status_bar(gui_main_handle);

end

%% sub-functions

function cal = get_cal_node(cal_ori,node)

cal = cal_ori;

if ~isempty(node.Cal)
    
    cal_temp_cell = node.Cal;
    
    if ~iscell(cal_temp_cell)
        cal_temp_cell = {cal_temp_cell};
    end
    
    cal = cell(1,length(cal_temp_cell));
    
    for icell = 1:length(cal_temp_cell)
        call_out_temp = [];
        for ical = 1:length(cal_temp_cell{icell})
            cal_temp = cal_temp_cell{icell};
            if ~isempty(cal_ori)
                call_out_temp = cal_ori;
                if any([call_out_temp(:).FREQ] == cal_temp(ical).FREQ)
                    call_out_temp([call_out_temp(:).FREQ] == cal_temp(ical).FREQ) = cal_temp(ical);
                else
                    call_out_temp(length(call_out_temp)+1) = cal_temp(ical);
                end
            else
                call_out_temp = cal_temp;
            end
        end
        cal{icell} = call_out_temp;
    end
    
    if length(cal) == 1
        cal = cal{1};
    end
    
end


end

