function Sv_freq_response_func(main_figure,reg_obj)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[~,idx_freq]=layer.get_trans(curr_disp);

f_vec=[];
Sv_f=[];

[cal_path,~,~]=fileparts(layer.Filename{1});

[regs,idx_freq_end]=layer.generate_regions_for_other_freqs(idx_freq,reg_obj,[]);

for uui=1:length(layer.Frequencies)
    reg=regs(idx_freq_end==uui);
    if isempty(reg)
        reg=reg_obj;
    end
    
    
    if strcmp(layer.Transceivers(uui).Mode,'FM')
        file_cal=fullfile(cal_path,['Curve_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
        

        if exist(file_cal_eba,'file')>0
            cal_eba=load(file_cal_eba);
            disp('EBA Calibration file loaded.');
        else
            cal_eba=[];
        end
        
        
        if exist(file_cal,'file')>0
            disp('Calibration file loaded.');
            cal=load(file_cal);
        else
            cal=[];
        end
              
        [Sv_f_temp,f_vec_temp,~,~]=layer.Transceivers(uui).sv_f_from_region(reg,'envdata',layer.EnvData,'cal',cal,'cal_eba',cal_eba);
        Sv_f_temp_mean=10*log10(nanmean(nanmean(10.^(Sv_f_temp/10))));
        Sv_f_temp_mean=permute(Sv_f_temp_mean,[2 3 1]);
        Sv_f=[Sv_f Sv_f_temp_mean];
        f_vec=[f_vec f_vec_temp];
        
              
        clear f_vec_temp Sv_f_temp
    else

              
        fprintf('%s not in  FM mode\n',layer.Transceivers(uui).Config.ChannelID);
        
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
        else
            tmp=10*log10(nanmean(10.^(Sv(:)/10)));
        end
         
        Sv_f=[Sv_f tmp];
        
        f_vec=[f_vec f_vec_temp];
        clear f_vec_temp
    end
end

[f_vec,idx_sort]=sort(f_vec);
Sv_f=Sv_f(idx_sort);


  layer.add_curves(curve_cl('XData',f_vec/1e3,...
      'YData',Sv_f,...
      'Type','Sv(f)',...
      'Xunit','kHz',...
      'Yunit','dB',...
      'Tag',reg_obj.Tag,...
      'Name',sprintf('%s %.0f',reg_obj.Name,reg_obj.ID),...
      'Unique_ID',reg_obj.Unique_ID));


update_multi_freq_disp_tab(main_figure);
end