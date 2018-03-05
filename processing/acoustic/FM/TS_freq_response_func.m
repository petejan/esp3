function TS_freq_response_func(main_figure,reg_obj)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');

ah=axes_panel_comp.main_axes;
clear_lines(ah);
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
range=trans_obj.get_transceiver_range();

idx_r=reg_obj.Idx_r;

r_max=nanmax(range(idx_r));

f_vec=[];

TS_f=[];
SD_f=[];

[cal_path,~,~]=fileparts(layer.Filename{1});

[~,idx_sort]=sort(layer.Frequencies);

leg_fig=cell(1,length(idx_sort));
i_leg=1;

[regs,idx_freq_end]=layer.generate_regions_for_other_freqs(idx_freq,reg_obj,[]);

for uui=idx_sort
    reg=regs(idx_freq_end==uui);
    
    if isempty(reg)
        reg=reg_obj;
    end
    
    leg_fig{i_leg}=sprintf('%.0f kHz',layer.Frequencies(uui)/1000);
    i_leg=i_leg+1;
    range=layer.Transceivers(uui).get_transceiver_range();
    
    idx_r=reg.Idx_r;
    idx_pings=reg.Idx_pings;
    idx_pings_red=1:numel(idx_pings);

    if isempty(idx_r)
        [~,idx_r]=nanmin(abs(range-r_max));
        reg.Idx_r=idx_r;
    end
    
    field='sp';
    if ismember('spdenoised',layer.Transceivers(uui).Data.Fieldname)
        field='spdenoised';
    end
    
    [Sp_red,~,~,bad_data_mask,bad_trans_vec,~,below_bot_mask,~]=layer.Transceivers(uui).get_data_from_region(reg,...
        'field',field);
    
    Sp_red(bad_data_mask|below_bot_mask)=nan;
    Sp_red(:,bad_trans_vec)=nan;
    
    
    [Sp_max,idx_peak_red]=nanmax(Sp_red,[],1);
    idx_peak=idx_r(idx_peak_red);
    
    
    if strcmp(layer.Transceivers(uui).Mode,'FM')
        if ~isempty(layer.Transceivers(uui).Config.Cal_FM)
%             %<FrequencyPar Frequency="222062" Gain="30.09" Impedance="75" Phase="0" BeamWidthAlongship="5.43" BeamWidthAthwartship="5.64" AngleOffsetAlongship="0.04" AngleOffsetAthwartship="0.04" />
%             cal_eba_ori.BeamWidthAlongship_f_fit=layer.Transceivers(uui).Config.Cal_FM.BeamWidthAlongship;
%             cal_eba_ori.BeamWidthAthwartship_f_fit=layer.Transceivers(uui).Config.Cal_FM.BeamWidthAthwartship;
%             cal_eba_ori.freq_vec=layer.Transceivers(uui).Config.Cal_FM.Frequency;             
            cal_ori.freq_vec=layer.Transceivers(uui).Config.Cal_FM.Frequency;
            cal_ori.Gf=layer.Transceivers(uui).Config.Cal_FM.Gain;
            
        else
            cal_ori=[];
            %cal_eba_ori=[];
        end
        
        
             
        file_cal=fullfile(cal_path,['Curve_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
        
        if exist(file_cal,'file')>0
            cal=load(file_cal);
            disp('Calibration file loaded.');
        elseif ~isempty(cal_ori)
            cal=cal_ori;
            disp('Using *.raw file calibration.');
        else
            disp('No calibration');
            cal=[];
        end
        
        idx_pings(isnan(Sp_max))=[];
        idx_peak(isnan(Sp_max))=[];
        set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',length(idx_pings), 'Value',0);
        load_bar_comp.status_bar.setText(sprintf('Processing TS estimation at %.0fkz',layer.Transceivers(uui).Params.Frequency(1)/1e3));
                
        for kk=1:length(idx_pings)
            [Sp_f(:,kk),Compensation_f(:,kk),f_vec_temp(:,kk)]=processTS_f_v2(layer.Transceivers(uui),layer.EnvData,idx_pings(kk),range(idx_peak(kk)),1,cal,[]);
            set(load_bar_comp.progress_bar,'Value',kk);
        end
        
        Compensation_f(Compensation_f>12)=nan;
        TS_f_tmp=(Sp_f+Compensation_f);
        tsf_f_tmp=(10.^(TS_f_tmp'/10));
        
        SD_f=[SD_f nanstd(TS_f_tmp')];
        SD_f=[];
        TS_f=[TS_f 10*log10(nanmean(tsf_f_tmp))];        
        f_vec=[f_vec f_vec_temp(:,1)'];
        
        
        clear Sp_f Compensation_f  f_vec_temp
    else
        %fprintf('%s not in  FM mode\n',layer.Transceivers(uui).Config.ChannelID);

        AlongAngle=layer.Transceivers(uui).Data.get_subdatamat(idx_r,idx_pings,'field','AlongAngle');
        AcrossAngle=layer.Transceivers(uui).Data.get_subdatamat(idx_r,idx_pings,'field','AcrossAngle');
        
        if isempty(AlongAngle)
             AlongAngle=zeros(numel(idx_r),numel(idx_pings));
        end
        
        if isempty(AcrossAngle)
            AcrossAngle=zeros(numel(idx_r),numel(idx_pings));
        end
        
        BeamWidthAlongship=layer.Transceivers(uui).Config.BeamWidthAlongship;
        BeamWidthAthwartship=layer.Transceivers(uui).Config.BeamWidthAthwartship;
        
      
        comp=simradBeamCompensation(BeamWidthAlongship,BeamWidthAthwartship , AcrossAngle((idx_pings_red-1)*length(idx_r)+idx_peak_red), AlongAngle((idx_pings_red-1)*length(idx_r)+idx_peak_red));
        comp(comp>12|comp<0)=nan;
        f_vec=[f_vec layer.Frequencies(uui)];
        TS_f_tmp=(Sp_max+comp);
        tsf_f_tmp=(10.^(TS_f_tmp(:)/10));
        
        SD_f=[SD_f nanstd(TS_f_tmp)];
        TS_f_tmp=10*log10(nanmean(tsf_f_tmp));
        TS_f=[TS_f TS_f_tmp];
    end
end


if ~isempty(f_vec)
    [f_vec,idx_sort]=sort(f_vec);
    TS_f=TS_f(idx_sort);
    
    layer.add_curves(curve_cl('XData',f_vec/1e3,...
        'YData',TS_f,...       
        'SD',SD_f,...
        'Type','ts_f',...
        'Xunit','kHz',...
        'Yunit','dB',...
        'Tag',reg_obj.Tag,...
        'Name',sprintf('%s %.0f %.0f kHz',reg_obj.Name,reg_obj.ID,layer.Frequencies(idx_freq)/1e3),...
        'Unique_ID',reg_obj.Unique_ID));

end

hide_status_bar(main_figure);
end
