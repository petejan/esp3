function load_processing_tab(main_figure,option_tab_panel)

if isappdata(main_figure,'Processing_tab')
    processing_tab_comp=getappdata(main_figure,'Processing_tab');
    delete(processing_tab_comp.processing_tab);
    rmappdata(main_figure,'Processing_tab');
end


process_list=getappdata(main_figure,'Process');
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

processing_tab_comp.processing_tab=uitab(option_tab_panel,'Title','Processing');


idx_freq=find_freq_idx(layer,curr_disp.Freq);
uicontrol(processing_tab_comp.processing_tab,'Style','Text','String','Frequency','units','normalized','Position',[0.05 0.85 0.1 0.1]);
processing_tab_comp.tog_freq=uicontrol(processing_tab_comp.processing_tab,'Style','popupmenu','String',num2str(layer.Frequencies'),'Value',idx_freq,'units','normalized','Position', [0.05 0.7 0.2 0.1],'Callback',{@tog_freq,main_figure});


if ~isempty(process_list)
    [~,~,found]=find_process_algo(process_list,curr_disp.Freq,'Denoise');
    noise_rem_algo=found;
    [~,~,found]=find_process_algo(process_list,curr_disp.Freq,'BottomDetection');
    bot_algo=found;
    [~,~,found]=find_process_algo(process_list,curr_disp.Freq,'BadPings');
    bad_trans_algo=found;
    [~,~,found]=find_process_algo(process_list,curr_disp.Freq,'SchoolDetection');
    school_detect_algo=found;
    [~,~,found]=find_process_algo(process_list,curr_disp.Freq,'SingleTarget');
    st_detect_algo=found;
    [~,~,found]=find_process_algo(process_list,curr_disp.Freq,'TrackTarget');
    track_algo=found;
else
    
    noise_rem_algo=0;
    bot_algo=0;
    bad_trans_algo=0;
    school_detect_algo=0;
    st_detect_algo=0;
    track_algo=0;
    
end

uicontrol(processing_tab_comp.processing_tab,'Style','Text','String','Algorithms','units','normalized','Position',[0.3 0.85 0.2 0.1]);
processing_tab_comp.noise_removal=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',noise_rem_algo,'String','Noise Removal','units','normalized','Position',[0.3 0.75 0.3 0.1]);
processing_tab_comp.bot_detec=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',bot_algo,'String','Bottom Detection','units','normalized','Position',[0.3 0.65 0.3 0.1]);
processing_tab_comp.bad_transmit=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',bad_trans_algo,'String','Bad Transmit Removal','units','normalized','Position',[0.3 0.55 0.3 0.1]);
processing_tab_comp.school_detec=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',school_detect_algo,'String','School detection','units','normalized','Position',[0.3 0.45 0.3 0.1]);
processing_tab_comp.single_target=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',st_detect_algo,'String','Single Target Detection','units','normalized','Position',[0.3 0.35 0.3 0.1]);
processing_tab_comp.track_target=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',track_algo,'String','Track Targets','units','normalized','Position',[0.3 0.25 0.3 0.1]);



set([processing_tab_comp.track_target processing_tab_comp.single_target processing_tab_comp.noise_removal processing_tab_comp.bot_detec processing_tab_comp.bad_transmit processing_tab_comp.school_detec],'Callback',{@update_process_list,main_figure})

uicontrol(processing_tab_comp.processing_tab,'Style','Text','String','File Selection','units','normalized','Position',[0.6 0.85 0.2 0.1]);
uicontrol(processing_tab_comp.processing_tab,'Style','pushbutton','String','Apply to current data','units','normalized','pos',[0.6 0.70 0.3 0.15],'callback',{@process,main_figure,0});
uicontrol(processing_tab_comp.processing_tab,'Style','pushbutton','String','Apply to all current layers','units','normalized','pos',[0.6 0.50 0.3 0.15],'callback',{@process,main_figure,1});


setappdata(main_figure,'Processing_tab',processing_tab_comp);
setappdata(main_figure,'Process',process_list);
end

function process(~,~,main_figure,mode)
update_process_list([],[],main_figure);
layer_curr=getappdata(main_figure,'Layer');
layers=getappdata(main_figure,'Layers');
process_list=getappdata(main_figure,'Process');

if layer_curr.ID_num==0
    return;
end

if mode==0
    layer_to_proc=layer_curr;
elseif mode ==1
    layer_to_proc=layers;
end


for ii=1:length(layer_to_proc)
    layer=layer_to_proc(ii);
    
    for kk=1:length(process_list)
        
        if isempty(process_list(kk).Algo)
            continue;
        end
        
        
        idx_freq=find_freq_idx(layer,process_list(kk).Freq);
        trans_obj=layer.Transceivers(idx_freq);
        
        
        [~,idx_algo_denoise,noise_rem_algo]=find_process_algo(process_list,process_list(kk).Freq,'Denoise');
        [~,idx_algo_bot,bot_algo]=find_process_algo(process_list,process_list(kk).Freq,'BottomDetection');
        [~,idx_algo_bp,bad_trans_algo]=find_process_algo(process_list,process_list(kk).Freq,'BadPings');
        [~,idx_school_detect,school_detect_algo]=find_process_algo(process_list,process_list(kk).Freq,'SchoolDetection');
        [~,idx_single_target,single_target_algo]=find_process_algo(process_list,process_list(kk).Freq,'SingleTarget');
        [~,idx_track_target,single_track_algo]=find_process_algo(process_list,process_list(kk).Freq,'TrackTarget');
        

        if noise_rem_algo
            trans_obj.add_algo(process_list(kk).Algo(idx_algo_denoise));
            trans_obj.apply_algo('Denoise');
        end
        
        if bot_algo&&~bad_trans_algo
           trans_obj.add_algo(process_list(kk).Algo(idx_algo_bot));
            trans_obj.apply_algo('BottomDetection');
        end
        
        
        if bad_trans_algo
             trans_obj.add_algo(process_list(kk).Algo(idx_algo_bp));
            trans_obj.apply_algo('BadPings');
            
        end
        
        if school_detect_algo
            
            if isempty(trans_obj.GPSDataPing.Dist)
                warning('SchoolDetection: No GPS data')
                return;
            end
            
            
            trans_obj.add_algo(process_list(kk).Algo(idx_school_detect));
            trans_obj.apply_algo('SchoolDetection');
            
        end
        
        if single_target_algo
             trans_obj.add_algo(process_list(kk).Algo(idx_single_target));
            trans_obj.apply_algo('SingleTarget');
            
            if single_track_algo
                trans_obj.add_algo(process_list(kk).Algo(idx_track_target));
                trans_obj.apply_algo('TrackTarget');

            end
            
            
        end
        
    end
    
end
setappdata(main_figure,'Layers',layers);
update_display(main_figure,0);

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
process_list=set_process_list(process_list,layer.Frequencies(idx_freq),trans_obj.Algo(idx_algo),add);

add=get(processing_tab_comp.bot_detec,'value')==get(processing_tab_comp.bot_detec,'max');
idx_algo=find_algo_idx(trans_obj,'BottomDetection');
process_list=set_process_list(process_list,layer.Frequencies(idx_freq),trans_obj.Algo(idx_algo),add);

add=get(processing_tab_comp.bad_transmit,'value')==get(processing_tab_comp.bad_transmit,'max');
idx_algo=find_algo_idx(trans_obj,'BadPings');
process_list=set_process_list(process_list,layer.Frequencies(idx_freq),trans_obj.Algo(idx_algo),add);

add=get(processing_tab_comp.school_detec,'value')==get(processing_tab_comp.school_detec,'max');
idx_algo=find_algo_idx(trans_obj,'SchoolDetection');
process_list=set_process_list(process_list,layer.Frequencies(idx_freq),trans_obj.Algo(idx_algo),add);

add_st=get(processing_tab_comp.single_target,'value')==get(processing_tab_comp.single_target,'max');
idx_algo=find_algo_idx(trans_obj,'SingleTarget');
process_list=set_process_list(process_list,layer.Frequencies(idx_freq),trans_obj.Algo(idx_algo),add_st);

if add_st==0
    set(processing_tab_comp.track_target,'value',get(processing_tab_comp.track_target,'min'));
end

add=get(processing_tab_comp.track_target,'value')==get(processing_tab_comp.track_target,'max');
idx_algo=find_algo_idx(trans_obj,'TrackTarget');

process_list=set_process_list(process_list,layer.Frequencies(idx_freq),trans_obj.Algo(idx_algo),add);

setappdata(main_figure,'Process',process_list);
end

function tog_freq(src,~,main_figure)
choose_freq(src,[],main_figure);
curr_disp=getappdata(main_figure,'Curr_disp');
process_list=getappdata(main_figure,'Process');
processing_tab_comp=getappdata(main_figure,'Processing_tab');

freq_vec=get(processing_tab_comp.tog_freq,'string');
idx_freq=get(processing_tab_comp.tog_freq,'value');

freq=str2double(freq_vec(idx_freq,:));

curr_disp.Freq=freq;
if ~isempty(process_list)
    [~,~,found]=find_process_algo(process_list,freq,'Denoise');
    noise_rem_algo=found;
    [~,~,found]=find_process_algo(process_list,freq,'BottomDetection');
    bot_algo=found;
    [~,~,found]=find_process_algo(process_list,freq,'BadPings');
    bad_trans_algo=found;
    [~,~,found]=find_process_algo(process_list,freq,'SchoolDetection');
    school_detect_algo=found;
else
    noise_rem_algo=0;
    bot_algo=0;
    bad_trans_algo=0;
    school_detect_algo=0;
end

set(processing_tab_comp.noise_removal,'value',noise_rem_algo);
set(processing_tab_comp.bot_detec,'value',bot_algo);
set(processing_tab_comp.bad_transmit,'value',bad_trans_algo);
set(processing_tab_comp.school_detec,'value',school_detect_algo);

end

function [voyage_path,rawFiles,iFiles]=getrawfiles()

rawFiles = {};
iFiles = {};
voyage_path=uigetdir();

u=strfind(voyage_path,'tan');

if ~isempty(u)
    voyage=upper(voyage_path(u(1):u(1)+6));
else
    return;
end

display(['Get rawfile names of trawl files for voyage: ', voyage]);
j=0;
tmpfold = dir(fullfile(voyage_path(1:end-5), 'i*')); % Assume i-files will be

for i = 1:length(tmpfold);                          % in parent directory for raw files
    tmpfile = tmpfold(i).name;
    ifileInfo = parse_ifile(voyage_path(1:end-5),tmpfile);
    if strcmp(ifileInfo.stratum, 'trawl')
        j=j+1;
        rawFiles{j} = ifileInfo.rawFileName;
        iFiles{j} = tmpfile;
    end
    
end

end

