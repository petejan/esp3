function Sv_freq_response_func(main_figure,reg_obj)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[~,idx_freq]=layer.get_trans(curr_disp);
show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
f_vec=[];
Sv_f=[];
SD_f=[];

[cal_path,~,~]=fileparts(layer.Filename{1});

[regs,idx_freq_end]=layer.generate_regions_for_other_freqs(idx_freq,reg_obj,[]);

for uui=1:length(layer.Frequencies)
    reg=regs(idx_freq_end==uui);
    if isempty(reg)
        reg=reg_obj;
    end
    
    
    if strcmp(layer.Transceivers(uui).Mode,'FM')
        file_cal=fullfile(cal_path,['Curve_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
        file_cal_eba=fullfile(cal_path,[ 'Curve_EBA_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
        
        
         if ~isempty(layer.Transceivers(uui).Config.Cal_FM)
             %<FrequencyPar Frequency="222062" Gain="30.09" Impedance="75" Phase="0" BeamWidthAlongship="5.43" BeamWidthAthwartship="5.64" AngleOffsetAlongship="0.04" AngleOffsetAthwartship="0.04" />
             cal_eba_ori.BeamWidthAlongship_f_fit=layer.Transceivers(uui).Config.Cal_FM.BeamWidthAlongship;
             cal_eba_ori.BeamWidthAthwartship_f_fit=layer.Transceivers(uui).Config.Cal_FM.BeamWidthAthwartship;
             cal_eba_ori.freq_vec=layer.Transceivers(uui).Config.Cal_FM.Frequency;             
            cal_ori.freq_vec=layer.Transceivers(uui).Config.Cal_FM.Frequency;
            cal_ori.Gf=layer.Transceivers(uui).Config.Cal_FM.Gain;
            
        else
            cal_ori=[];
            cal_eba_ori=[];
        end

        if exist(file_cal_eba,'file')>0
            cal_eba=load(file_cal_eba);
        elseif ~isempty(cal_eba_ori)
            cal_eba=cal_eba_ori;
        else
            cal_eba=[];
        end
        
        
        if exist(file_cal,'file')>0
            disp('Calibration file loaded.');
            cal=load(file_cal);
        elseif ~isempty(cal_ori)
            cal=cal_ori;
             disp('Using *.raw file calibration.');
        else
            cal=[];
        end
        
        load_bar_comp.status_bar.setText(sprintf('Processing Sv estimation at %.0fkz',layer.Transceivers(uui).Params.Frequency(1)/1e3));
                      
        [Sv_f_temp,f_vec_temp,~,~]=layer.Transceivers(uui).sv_f_from_region(reg,'envdata',layer.EnvData,'cal',cal,'cal_eba',cal_eba);
        
        sv_f_temp=10.^(Sv_f_temp/10);
        Sv_f_temp=10*log10(nanmean(nanmean(sv_f_temp)));
        SD_f_temp=nanstd(10*log10(nanmean(sv_f_temp)));
        
        Sv_f_temp=permute(Sv_f_temp,[2 3 1]);
        
        %SD_f=[SD_f SD_f_temp]; 
        SD_f=[];
        Sv_f=[Sv_f Sv_f_temp];
        f_vec=[f_vec f_vec_temp];
        
              
        clear f_vec_temp Sv_f_temp
    else              
        %fprintf('%s not in  FM mode\n',layer.Transceivers(uui).Config.ChannelID);
        
        f_vec_temp=layer.Frequencies(uui);
        

        field='sv';
        if ismember('svdenoised',layer.Transceivers(uui).Data.Fieldname)
           field='svdenoised';
        end
        
        [Sv,~,~,bad_data_mask,bad_trans_vec,~,below_bot_mask,~]=layer.Transceivers(uui).get_data_from_region(reg,...
            'field',field);
        Sv(bad_data_mask|below_bot_mask)=nan;
        Sv(:,bad_trans_vec)=nan;
       
        if all(Sv(:)==-999|isnan(Sv(:)))
            tmp=nan;
            SD_f_temp=nan;
        else
            sv_lin=(10.^(Sv(:)/10));
            SD_f_temp=nanstd(Sv(:));
            tmp=10*log10(nanmean(sv_lin));
        end
         
        Sv_f=[Sv_f tmp];
        
        SD_f=[SD_f SD_f_temp]; 
        f_vec=[f_vec f_vec_temp];
        clear f_vec_temp
    end
end

if~isempty(f_vec)
    [f_vec,idx_sort]=sort(f_vec);
    Sv_f=Sv_f(idx_sort);
       
    layer.add_curves(curve_cl('XData',f_vec/1e3,...
        'YData',Sv_f,...
        'SD',SD_f,...
        'Type','sv_f',...
        'Xunit','kHz',...
        'Yunit','dB',...
        'Tag',reg_obj.Tag,...
        'Name',sprintf('%s %.0f %.0fkHz',reg_obj.Name,reg_obj.ID,layer.Frequencies(idx_freq)/1e3),...
        'Unique_ID',reg_obj.Unique_ID));
       
end


hide_status_bar(main_figure);
end