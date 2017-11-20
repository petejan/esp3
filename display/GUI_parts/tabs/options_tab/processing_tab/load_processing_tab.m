%% load_processing_tab.m
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
% * |main_figure|: TODO: write description and info on variable
% * |option_tab_panel|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function load_processing_tab(main_figure,option_tab_panel)

processing_tab_comp.processing_tab=uitab(option_tab_panel,'Title','Processing');


uicontrol(processing_tab_comp.processing_tab,'Style','Text','String','Frequency','units','normalized','Position',[0.05 0.85 0.2 0.1]);
processing_tab_comp.tog_freq=uicontrol(processing_tab_comp.processing_tab,'Style','popupmenu','String','--','Value',1,'units','normalized','Position', [0.05 0.7 0.2 0.1],'Callback',{@tog_freq,main_figure});


uicontrol(processing_tab_comp.processing_tab,'Style','Text','String','Algorithms','units','normalized','Position',[0.3 0.85 0.2 0.1]);
processing_tab_comp.noise_removal=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',0,'String','Noise Removal','units','normalized','Position',[0.3 0.75 0.3 0.1]);
processing_tab_comp.bot_detec=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',0,'String','Bottom Detection','units','normalized','Position',[0.3 0.65 0.3 0.1]);
processing_tab_comp.bot_detec_v2=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',0,'String','Bottom Detection V2','units','normalized','Position',[0.3 0.55 0.3 0.1]);
processing_tab_comp.bad_transmit=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',0,'String','Bad Transmit Removal','units','normalized','Position',[0.3 0.45 0.3 0.1]);
processing_tab_comp.school_detec=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',0,'String','School detection','units','normalized','Position',[0.3 0.35 0.3 0.1]);
processing_tab_comp.single_target=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',0,'String','Single Target Detection','units','normalized','Position',[0.3 0.25 0.3 0.1]);
processing_tab_comp.track_target=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',0,'String','Track Targets','units','normalized','Position',[0.3 0.15 0.3 0.1]);



set([processing_tab_comp.track_target ...
    processing_tab_comp.single_target ...
    processing_tab_comp.noise_removal ...
    processing_tab_comp.bot_detec ...
    processing_tab_comp.bot_detec_v2 ...
    processing_tab_comp.bad_transmit ...
    processing_tab_comp.school_detec]...
    ,'Callback',{@update_process_list,main_figure})

uicontrol(processing_tab_comp.processing_tab,'Style','pushbutton','String','Apply to current layer','units','normalized','pos',[0.6 0.70 0.2 0.15],'callback',{@process,main_figure,0});
uicontrol(processing_tab_comp.processing_tab,'Style','pushbutton','String','Apply to all loaded layers','units','normalized','pos',[0.6 0.50 0.2 0.15],'callback',{@process,main_figure,1});
uicontrol(processing_tab_comp.processing_tab,'Style','pushbutton','String','Select *.raw files','units','normalized','pos',[0.6 0.30 0.2 0.15],'callback',{@process,main_figure,2});

%set(findall(processing_tab_comp.processing_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'Processing_tab',processing_tab_comp);

end

function process(~,~,main_figure,mode)
update_process_list([],[],main_figure);
layer_curr=getappdata(main_figure,'Layer');
layers=getappdata(main_figure,'Layers');
process_list=getappdata(main_figure,'Process');
app_path = getappdata(main_figure,'App_path');
load_bar_comp=getappdata(main_figure,'Loading_bar');

show_status_bar(main_figure);
if mode==0
    layer_to_proc=layer_curr;
elseif mode ==1
    layer_to_proc=layers;
elseif mode==2
    
    %%% Get a default path for the file selection dialog box
    if ~isempty(layer_curr)
        [path_lay,~] = layer_curr.get_path_files();
        if ~isempty(path_lay)
            % if file(s) already loaded, same path as first one in list
            file_path = path_lay{1};
        else
            % config default path if none
            file_path = app_path.data;
        end
    else
        % config default path if none
        file_path = app_path.data;
    end
    [Filename,path_f] = uigetfile( {fullfile(file_path,'*.raw')}, 'Pick a set of raw file','MultiSelect','on');
    if isempty(Filename)
        return;
    end
    
    % single file is char. Turn to cell
    if ~iscell(Filename)
        if (Filename==0)
            return;
        end
        Filename = {Filename};
    end
    
    % keep only supported files, exit if none
    idx_keep =~ cellfun(@isempty,regexp(Filename(:),'(raw$)'));
    Filename = Filename(idx_keep);
    if isempty(Filename)
        return;
    end
    layer_to_proc=cellfun(@(x) fullfile(path_f,x),Filename,'UniformOutput',0);
    
end

show_status_bar(main_figure);
for ii=1:length(layer_to_proc)
    
    switch mode
        case {0,1}
            layer=layer_to_proc(ii);
        case {2}
            layer=open_EK_file_stdalone(layer_to_proc{ii},...
                'PathToMemmap',app_path.data_temp,'load_bar_comp',load_bar_comp);
            load_bar_comp.status_bar.setText('Updating Database with GPS Data');
            layer.add_gps_data_to_db();
    end
    
    
    for kk=1:length(process_list)
        
        if isempty(process_list(kk).Algo)
            continue;
        end
        
        
        trans_obj=layer.get_trans(process_list(kk).Freq);
        
        if isempty(trans_obj)
            fprintf('Could not find %.0fkhz on this layer\n',process_list(kk).Freq/1e3);
            continue;
        end

        
       
        [~,idx_algo_denoise,noise_rem_algo]=find_process_algo(process_list,process_list(kk).Freq,'Denoise');
        [~,idx_algo_bot,bot_algo]=find_process_algo(process_list,process_list(kk).Freq,'BottomDetection');
        [~,idx_algo_bot_v2,bot_algo_v2]=find_process_algo(process_list,process_list(kk).Freq,'BottomDetectionV2');
        [~,idx_algo_bp,bad_trans_algo]=find_process_algo(process_list,process_list(kk).Freq,'BadPingsV2');
        [~,idx_school_detect,school_detect_algo]=find_process_algo(process_list,process_list(kk).Freq,'SchoolDetection');
        [~,idx_single_target,single_target_algo]=find_process_algo(process_list,process_list(kk).Freq,'SingleTarget');
        [~,idx_track_target,single_track_algo]=find_process_algo(process_list,process_list(kk).Freq,'TrackTarget');
        
        
        if noise_rem_algo
            trans_obj.add_algo(process_list(kk).Algo(idx_algo_denoise));
            trans_obj.apply_algo('Denoise','load_bar_comp',load_bar_comp);
        end
        
        if bot_algo
            trans_obj.add_algo(process_list(kk).Algo(idx_algo_bot));
            trans_obj.apply_algo('BottomDetection','load_bar_comp',load_bar_comp);
        end
        
        if bot_algo_v2
            trans_obj.add_algo(process_list(kk).Algo(idx_algo_bot_v2));
            trans_obj.apply_algo('BottomDetectionV2','load_bar_comp',load_bar_comp);
        end
        
        if bad_trans_algo
            trans_obj.add_algo(process_list(kk).Algo(idx_algo_bp));
            trans_obj.apply_algo('BadPingsV2','load_bar_comp',load_bar_comp);
        end
        
        if school_detect_algo
                 
            trans_obj.add_algo(process_list(kk).Algo(idx_school_detect));
            trans_obj.apply_algo('SchoolDetection','load_bar_comp',load_bar_comp);
            
        end
        
        if single_target_algo
            trans_obj.add_algo(process_list(kk).Algo(idx_single_target));
            trans_obj.apply_algo('SingleTarget','load_bar_comp',load_bar_comp);
            
            if single_track_algo
                trans_obj.add_algo(process_list(kk).Algo(idx_track_target));
                trans_obj.apply_algo('TrackTarget','load_bar_comp',load_bar_comp);
                
            end
            
            
        end
        
    end
    if mode==2
        load_bar_comp.status_bar.setText('Saving Resulting Bottom and regions');
        layer.write_reg_to_reg_xml();
        layer.write_bot_to_bot_xml();
        layer.rm_memaps();
        delete(layer);
    end
end

hide_status_bar(main_figure);
setappdata(main_figure,'Layers',layers);
display_bottom(main_figure);
set_alpha_map(main_figure);

display_regions(main_figure,'both');
curr_disp=getappdata(main_figure,'Curr_disp');
trans_obj=layer_curr.get_trans(curr_disp);
curr_disp.Active_reg_ID=trans_obj.get_reg_first_Unique_ID();

order_stacks_fig(main_figure);

end

function update_process_list(~,~,main_figure)
update_algos(main_figure)
layer=getappdata(main_figure,'Layer');
process_list=getappdata(main_figure,'Process');
processing_tab_comp=getappdata(main_figure,'Processing_tab');
idx_freq=get(processing_tab_comp.tog_freq, 'value');
trans_obj=layer.Transceivers(idx_freq);

if isempty(trans_obj.Algo)
    return;
end

add=get(processing_tab_comp.noise_removal,'value')==get(processing_tab_comp.noise_removal,'max');
idx_algo=find_algo_idx(trans_obj,'Denoise');
process_list=process_list.set_process_list(layer.Frequencies(idx_freq),trans_obj.Algo(idx_algo),add);

add=get(processing_tab_comp.bot_detec,'value')==get(processing_tab_comp.bot_detec,'max');
idx_algo=find_algo_idx(trans_obj,'BottomDetection');
process_list=process_list.set_process_list(layer.Frequencies(idx_freq),trans_obj.Algo(idx_algo),add);

add=get(processing_tab_comp.bot_detec_v2,'value')==get(processing_tab_comp.bot_detec_v2,'max');
idx_algo=find_algo_idx(trans_obj,'BottomDetectionV2');
process_list=process_list.set_process_list(layer.Frequencies(idx_freq),trans_obj.Algo(idx_algo),add);

add=get(processing_tab_comp.bad_transmit,'value')==get(processing_tab_comp.bad_transmit,'max');
idx_algo=find_algo_idx(trans_obj,'BadPingsV2');
process_list=process_list.set_process_list(layer.Frequencies(idx_freq),trans_obj.Algo(idx_algo),add);

add=get(processing_tab_comp.school_detec,'value')==get(processing_tab_comp.school_detec,'max');
idx_algo=find_algo_idx(trans_obj,'SchoolDetection');
process_list=process_list.set_process_list(layer.Frequencies(idx_freq),trans_obj.Algo(idx_algo),add);

add_st=get(processing_tab_comp.single_target,'value')==get(processing_tab_comp.single_target,'max');
idx_algo=find_algo_idx(trans_obj,'SingleTarget');
process_list=process_list.set_process_list(layer.Frequencies(idx_freq),trans_obj.Algo(idx_algo),add_st);


add=get(processing_tab_comp.track_target,'value')==get(processing_tab_comp.track_target,'max');
idx_algo=find_algo_idx(trans_obj,'TrackTarget');
process_list=process_list.set_process_list(layer.Frequencies(idx_freq),trans_obj.Algo(idx_algo),add);

setappdata(main_figure,'Process',process_list);
end

function tog_freq(src,~,main_figure)
choose_freq(src,[],main_figure);
curr_disp=getappdata(main_figure,'Curr_disp');
process_list=getappdata(main_figure,'Process');
processing_tab_comp=getappdata(main_figure,'Processing_tab');

freq_vec=get(processing_tab_comp.tog_freq,'string');
idx_freq=get(processing_tab_comp.tog_freq,'value');
layer=getappdata(main_figure,'Layer');

freq=str2double(freq_vec(idx_freq,:));
curr_disp.ChannelID=layer.ChannelID{idx_freq};

if ~isempty(process_list)
    [~,~,found]=find_process_algo(process_list,freq,'Denoise');
    noise_rem_algo=found;
    [~,~,found]=find_process_algo(process_list,freq,'BottomDetectionV2');
    bot_algo_v2=found;
    [~,~,found]=find_process_algo(process_list,freq,'BottomDetection');
    bot_algo=found;
    [~,~,found]=find_process_algo(process_list,freq,'BadPingsV2');
    bad_trans_algo=found;
    [~,~,found]=find_process_algo(process_list,freq,'SchoolDetection');
    school_detect_algo=found;
else
    noise_rem_algo=0;
    bot_algo=0;
    bad_trans_algo=0;
    school_detect_algo=0;
    bot_algo_v2=0;
end

set(processing_tab_comp.noise_removal,'value',noise_rem_algo);
set(processing_tab_comp.bot_detec,'value',bot_algo);
set(processing_tab_comp.bot_detec_v2,'value',bot_algo_v2);
set(processing_tab_comp.bad_transmit,'value',bad_trans_algo);
set(processing_tab_comp.school_detec,'value',school_detect_algo);

end

