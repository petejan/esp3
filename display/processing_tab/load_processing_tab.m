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
else
    
    noise_rem_algo=0;
    
    bot_algo=0;
    
    bad_trans_algo=0;
    
    school_detect_algo=0;
    
end

uicontrol(processing_tab_comp.processing_tab,'Style','Text','String','Algorithms','units','normalized','Position',[0.3 0.85 0.2 0.1]);
processing_tab_comp.noise_removal=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',noise_rem_algo,'String','Noise Removal','units','normalized','Position',[0.3 0.7 0.3 0.15]);
processing_tab_comp.bot_detec=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',bot_algo,'String','Bottom Detection','units','normalized','Position',[0.3 0.55 0.3 0.15]);
processing_tab_comp.bad_transmit=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',bad_trans_algo,'String','Bad Transmit Removal','units','normalized','Position',[0.3 0.4 0.3 0.15]);
processing_tab_comp.school_detec=uicontrol(processing_tab_comp.processing_tab,'Style','checkbox','Value',school_detect_algo,'String','School detection','units','normalized','Position',[0.3 0.25 0.3 0.15]);

set([processing_tab_comp.noise_removal processing_tab_comp.bot_detec processing_tab_comp.bad_transmit processing_tab_comp.school_detec],'Callback',{@update_process_list,main_figure})

uicontrol(processing_tab_comp.processing_tab,'Style','Text','String','File Selection','units','normalized','Position',[0.6 0.85 0.2 0.1]);
uicontrol(processing_tab_comp.processing_tab,'Style','pushbutton','String','Apply to current data','units','normalized','pos',[0.6 0.70 0.3 0.15],'callback',{@process,main_figure,0});
uicontrol(processing_tab_comp.processing_tab,'Style','pushbutton','String','Choose files manually','units','normalized','pos',[0.6 0.50 0.3 0.15],'callback',{@process,main_figure,1});
uicontrol(processing_tab_comp.processing_tab,'Style','pushbutton','String','Select Trawl Files from Voyage','units','normalized','pos',[0.6 0.3 0.3 0.15],'callback',{@process,main_figure,2});


setappdata(main_figure,'Processing_tab',processing_tab_comp);

end

function process(~,~,main_figure,mode)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
process_list=getappdata(main_figure,'Process');

if mode==1
    if ~isempty(layer.PathToFile)
        path=layer.PathToFile;
    else
        path=pwd;
    end
    
    [Filename,PathToFile]= uigetfile([path '/*.raw'], 'Pick a raw file','MultiSelect','on');
    
    if ~iscell(Filename)
        Filename={Filename};
    end
    
elseif mode ==0
    Filename=1;
elseif mode==2
   [PathToFile,Filename,~]=getrawfiles(); 
end
    

for ii=1:length(Filename)
%for ii=1:3
    if mode>0
        open_file([],[],fullfile(PathToFile,Filename{ii}),main_figure);
        update_algos(main_figure);
        layer=getappdata(main_figure,'Layer');
    end
   
    for kk=1:length(process_list)
        
        curr_disp.Freq=process_list(kk).Freq;
        idx_freq=find_freq_idx(layer,curr_disp.Freq);
        idx_type_pow=find_type_idx(layer.Transceivers(idx_freq).Data,'Power');
        
        curr_disp.Type='Sv';
        setappdata(main_figure,'Curr_disp',curr_disp);
        load_axis_panel(main_figure,0);
        
        [~,idx_algo_denoise,noise_rem_algo]=find_process_algo(process_list,curr_disp.Freq,'Denoise');
        [~,idx_algo_bot,bot_algo]=find_process_algo(process_list,curr_disp.Freq,'BottomDetection');
        [~,idx_algo_bp,bad_trans_algo]=find_process_algo(process_list,curr_disp.Freq,'BadPings');
        [~,idx_school_detect,school_detect_algo]=find_process_algo(process_list,curr_disp.Freq,'SchoolDetection');
        
        
        
        if noise_rem_algo
            Transceiver=layer.Transceivers(idx_freq);
            f_s_sig=round(1/(Transceiver.Params.SampleInterval(1)));
            c=(layer.EnvData.SoundSpeed);
            FreqStart=(Transceiver.Params.FrequencyStart(1));
            FreqEnd=(Transceiver.Params.FrequencyEnd(1));
            Freq=(Transceiver.Config.Frequency);
            ptx=(Transceiver.Params.TransmitPower(1));
            pulse_length=double(Transceiver.Params.PulseLength(1));
            gains=Transceiver.Config.Gain;
            pulse_lengths=Transceiver.Config.PulseLength;
            eq_beam_angle=Transceiver.Config.EquivalentBeamAngle;
            [~,idx_pulse]=nanmin(abs(pulse_lengths-pulse_length));
            gain=gains(idx_pulse);
            FreqCenter=(FreqStart+FreqEnd)/2;
            lambda=c/FreqCenter;
            eq_beam_angle_curr=eq_beam_angle+20*log10(Freq/(FreqCenter));
            alpha=double(Transceiver.Params.Absorbtion);
            sacorr=2*Transceiver.Config.SaCorrection(idx_pulse);
            
            if strcmp(Transceiver.Mode,'FM')
                [simu_pulse,~]=generate_sim_pulse(Transceiver.Params,Transceiver.Filters(1),Transceiver.Filters(2));
                pulse_auto_corr=xcorr(simu_pulse)/nansum(abs(simu_pulse).^2);
                t_eff=nansum(abs(pulse_auto_corr).^2)/(nanmax(abs(pulse_auto_corr).^2)*f_s_sig);
            else
                t_eff=pulse_length;
            end
            power=layer.Transceivers(idx_freq).Data.SubData(idx_type_pow).DataMat;
            
            [power_unoised,Sv_unoised,Sp_unoised,SNR]=feval(process_list(kk).Algo(idx_algo_denoise).Function,...
                power,...
                layer.Transceivers(idx_freq).Data.Range,...
                c,alpha,t_eff,ptx,lambda,gain,eq_beam_angle_curr,sacorr,...
                'HorzFilt',process_list(kk).Algo(idx_algo_denoise).Varargin.HorzFilt,...
                'SNRThr',process_list(kk).Algo(idx_algo_denoise).Varargin.SNRThr,...
                'VertFilt',process_list(kk).Algo(idx_algo_denoise).Varargin.VertFilt,...
                'NoiseThr',process_list(kk).Algo(idx_algo_denoise).Varargin.NoiseThr);
            
            sub_ac_data_temp=[sub_ac_data_cl('Power Denoised',power_unoised) ...
                sub_ac_data_cl('Sp Denoised',Sp_unoised) ...
                sub_ac_data_cl('Sv Denoised',Sv_unoised) ...
                sub_ac_data_cl('SNR',SNR)];
            
            layer.Transceivers(idx_freq).Data.add_sub_data(sub_ac_data_temp);
            curr_disp.Type='Sv Denoised';
        end
        
        denoised=noise_rem_algo;
        
        if denoised>0
            [idx_type_sv,found]=find_type_idx(layer.Transceivers(idx_freq).Data,'Sv Denoised');
            curr_disp.Type='Sv Denoised';
            if found==0
                [idx_type_sv,~]=find_type_idx(layer.Transceivers(idx_freq).Data,'Sv');
                curr_disp.Type='Sv';
            end
        else
            [idx_type_sv,~]=find_type_idx(layer.Transceivers(idx_freq).Data,'Sv');
            curr_disp.Type='Sv';
        end
        
        
        
        if bot_algo&&~bad_trans_algo
            [Bottom,Double_bottom_region,~,~,~]=feval(process_list(kk).Algo(idx_algo_bot).Function,layer.Transceivers(idx_freq).Data.SubData(idx_type_sv).DataMat,...
                layer.Transceivers(idx_freq).Data.Range,...
                1/layer.Transceivers(idx_freq).Params.SampleInterval(1),...
                layer.Transceivers(idx_freq).Params.PulseLength(1),...
                'thr_bottom',process_list(kk).Algo(idx_algo_bot).Varargin.thr_bottom,...
                'thr_echo',process_list(kk).Algo(idx_algo_bot).Varargin.thr_echo,...
                'r_min',process_list(kk).Algo(idx_algo_bot).Varargin.r_min,...
                'r_max',process_list(kk).Algo(idx_algo_bot).Varargin.r_max);
            
            range=layer.Transceivers(idx_freq).Data.Range;
            bottom_range=nan(size(Bottom));
            bottom_range(~isnan(Bottom))=range(Bottom(~isnan(Bottom)));
            
            layer.Transceivers(idx_freq).Bottom=bottom_cl('Origin','Algo_v2',...
                'Range', bottom_range,...
                'Sample_idx',Bottom,...
                'Double_bot_mask',Double_bottom_region);
        end
        
        
        if bad_trans_algo
            [Bottom,Double_bottom_region,idx_noise_sector]=feval(process_list(kk).Algo(idx_algo_bp).Function,layer.Transceivers(idx_freq).Data.SubData(idx_type_sv).DataMat,...
                layer.Transceivers(idx_freq).Data.Range,...
                1/layer.Transceivers(idx_freq).Params.SampleInterval(1),...
                layer.Transceivers(idx_freq).Params.PulseLength(1),...
                'thr_bottom',process_list(kk).Algo(idx_algo_bp).Varargin.thr_bottom,...
                'thr_echo',process_list(kk).Algo(idx_algo_bp).Varargin.thr_echo,...
                'r_min',process_list(kk).Algo(idx_algo_bp).Varargin.r_min,...
                'r_max',process_list(kk).Algo(idx_algo_bp).Varargin.r_max,...
                'BS_std',process_list(kk).Algo(idx_algo_bp).Varargin.BS_std,...
                'thr_spikes_Above',process_list(kk).Algo(idx_algo_bp).Varargin.thr_spikes_Above,...
                'thr_spikes_Below',process_list(kk).Algo(idx_algo_bp).Varargin.thr_spikes_Below,...
                'Above',process_list(kk).Algo(idx_algo_bp).Varargin.Above,...
                'Below',process_list(kk).Algo(idx_algo_bp).Varargin.Below,...
                'burst_removal',false);
            
            range=layer.Transceivers(idx_freq).Data.Range;
            bottom_range=nan(size(Bottom));
            bottom_range(~isnan(Bottom))=range(Bottom(~isnan(Bottom)));
            
            layer.Transceivers(idx_freq).IdxBad=find(idx_noise_sector);
            layer.Transceivers(idx_freq).Bottom=bottom_cl('Origin','Algo_v2',...
                'Range', bottom_range,...
                'Sample_idx',Bottom,...
                'Double_bot_mask',Double_bottom_region);
            
        end
        
        if school_detect_algo
            
            switch layer.Transceivers(idx_freq).Mode
                case 'FM'
                    [simu_pulse,~]=generate_sim_pulse(layer.Transceivers(idx_freq).Params,layer.Transceivers(idx_freq).Filters(1),layer.Transceivers(idx_freq).Filters(2));
                    y_tx_auto=xcorr(simu_pulse)/nansum(abs(simu_pulse).^2);
                    t_eff_c=nansum(abs(y_tx_auto).^2)/(nanmax(abs(y_tx_auto).^2)*1/(layer.Transceivers(idx_freq).Params.SampleInterval(1)));
                    Np=round(t_eff_c/layer.Transceivers(idx_freq).Params.SampleInterval(1));
                case 'CW'
                    Np=round(layer.Transceivers(idx_freq).Params.PulseLength(1)/layer.Transceivers(idx_freq).Params.SampleInterval(1));
            end
            
            if isempty(layer.Transceivers(idx_freq).GPSDataPing.Dist)
                warning('SchoolDetection: No GPS data')
                return;
            end
            
            Sv=layer.Transceivers(idx_freq).Data.SubData(idx_type_sv).DataMat;
            
            linked_candidates=feval(process_list(kk).Algo(idx_school_detect).Function,layer.Transceivers(idx_freq),...
			'Type',curr_disp.Type,...
                'Sv_thr',process_list(kk).Algo(idx_school_detect).Varargin.Sv_thr,...
                'l_min_can',process_list(kk).Algo(idx_school_detect).Varargin.l_min_can,...
                'h_min_tot',process_list(kk).Algo(idx_school_detect).Varargin.h_min_tot,...
                'h_min_can',process_list(kk).Algo(idx_school_detect).Varargin.h_min_can,...
                'l_min_tot',process_list(kk).Algo(idx_school_detect).Varargin.l_min_tot,...
                'nb_min_sples',process_list(kk).Algo(idx_school_detect).Varargin.nb_min_sples,...
                'horz_link_max',process_list(kk).Algo(idx_school_detect).Varargin.horz_link_max,...
                'vert_link_max',process_list(kk).Algo(idx_school_detect).Varargin.vert_link_max);
            
            [nb_samples,nb_pings]=size(linked_candidates);
            
            y=layer.Transceivers(idx_freq).Data.Range;
            x=double(layer.Transceivers(idx_freq).Data.Number);
            
            layer.Transceivers(idx_freq).rm_region('School');
            
            region_tab_comp=getappdata(main_figure,'Region_tab');
            
            w_units=get(region_tab_comp.cell_w_unit,'string');
            w_unit_idx=get(region_tab_comp.cell_w_unit,'value');
            w_unit=w_units{w_unit_idx};
            
            h_units=get(region_tab_comp.cell_h_unit,'string');
            h_unit_idx=get(region_tab_comp.cell_h_unit,'value');
            h_unit=h_units{h_unit_idx};
            
            cell_h=str2double(get(region_tab_comp.cell_h,'string'));
            cell_w=str2double(get(region_tab_comp.cell_w,'string'));
            
            
            for j=1:nanmax(linked_candidates(:))
                curr_reg=(linked_candidates==j);
                curr_Sv=Sv;
                curr_Sv(~curr_reg)=nan;
                [J,I]=find(curr_reg);
                if ~isempty(J)
                    
                    
                    reg_temp=region_cl(...
                        'ID',new_id(layer.Transceivers(idx_freq),'Data'),...
                        'Name','School',...
                        'Type','Data',...
                        'Ping_ori',nanmax(nanmin(I)-1,1)+x(1)-1,...
                        'Sample_ori',nanmax(nanmin(J)-1,1),...
                        'BBox_w',(nanmax(I)-nanmin(I)),...
                        'BBox_h',(nanmax(J)-nanmin(J)),...
                        'Shape','Polygon',...
                        'Sv_reg',(curr_Sv(nanmax(nanmin(J)-1,1):nanmin(nanmax(J)+1,nb_samples),nanmax(nanmin(I)-1,1):nanmin(nanmax(I)+1,nb_pings))),...
                        'Reference','Surface',...
                        'Cell_w',cell_w,...
                        'Cell_w_unit',w_unit,...
                        'Cell_h',cell_h,...
                        'Cell_h_unit',h_unit,...
                        'Output',[]);
                    
                    idx_pings=nanmax(nanmin(I)-1,1):nanmin(nanmax(I)+1,nb_pings);
                    idx_r=nanmax(nanmin(J)-1,1):nanmin(nanmax(J)+1,nb_samples);

                    reg_temp.integrate_region(layer.Transceivers(idx_freq),idx_pings,idx_r);
                    
                    layer.Transceivers(idx_freq).add_region(reg_temp);
                    
                end
            end
        end
        
        main_childs=get(main_figure,'children');
        tags=get(main_childs,'Tag');
        idx_opt=strcmp(tags,'option_tab_panel');
        load_regions_tab(main_figure,main_childs(idx_opt));
        setappdata(main_figure,'Layer',layer);
        setappdata(main_figure,'Curr_disp',curr_disp);
        load_axis_panel(main_figure,0);
    end
    
end


end

function update_process_list(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
process_list=getappdata(main_figure,'Process');
processing_tab_comp=getappdata(main_figure,'Processing_tab');
idx_freq=get(processing_tab_comp.tog_freq, 'value');

add=get(processing_tab_comp.noise_removal,'value')==get(processing_tab_comp.noise_removal,'max');
idx_algo=find_algo_idx(layer.Transceivers(idx_freq),'Denoise');
process_list=set_process_list(process_list,layer.Frequencies(idx_freq),layer.Transceivers(idx_freq).Algo(idx_algo),add);

add=get(processing_tab_comp.bot_detec,'value')==get(processing_tab_comp.bot_detec,'max');
idx_algo=find_algo_idx(layer.Transceivers(idx_freq),'BottomDetection');
process_list=set_process_list(process_list,layer.Frequencies(idx_freq),layer.Transceivers(idx_freq).Algo(idx_algo),add);

add=get(processing_tab_comp.bad_transmit,'value')==get(processing_tab_comp.bad_transmit,'max');
idx_algo=find_algo_idx(layer.Transceivers(idx_freq),'BadPings');
process_list=set_process_list(process_list,layer.Frequencies(idx_freq),layer.Transceivers(idx_freq).Algo(idx_algo),add);

add=get(processing_tab_comp.school_detec,'value')==get(processing_tab_comp.school_detec,'max');
idx_algo=find_algo_idx(layer.Transceivers(idx_freq),'SchoolDetection');
process_list=set_process_list(process_list,layer.Frequencies(idx_freq),layer.Transceivers(idx_freq).Algo(idx_algo),add);


setappdata(main_figure,'Process',process_list);
end

function tog_freq(~,~,main_figure)

process_list=getappdata(main_figure,'Process');
processing_tab_comp=getappdata(main_figure,'Processing_tab');

freq_vec=get(processing_tab_comp.tog_freq,'string');
idx_freq=get(processing_tab_comp.tog_freq,'value');

freq=str2double(freq_vec(idx_freq,:));

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
    ifileInfo = get_ifile_info(voyage_path(1:end-5),tmpfile);
    if strcmp(ifileInfo.stratum, 'trawl')
        j=j+1;
        rawFiles{j} = ifileInfo.rawFileName;
        iFiles{j} = tmpfile;
    end
    
end

end

