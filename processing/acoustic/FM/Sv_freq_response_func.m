function Sv_freq_response_func(main_figure,idx_r,idx_pings)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,~]=layer.get_trans(curr_disp);
range=trans_obj.get_transceiver_range();

r_min=nanmin(range(idx_r));
r_max=nanmax(range(idx_r));


f_vec=[];
Sv_f=[];


[cal_path,~,~]=fileparts(layer.Filename{1});


for uui=1:length(layer.Frequencies)
    if strcmp(layer.Transceivers(uui).Mode,'FM')
        file_cal=fullfile(cal_path,['Curve_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
        
        file_cal_eba=fullfile(cal_path,[ 'Curve_EBA_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
        range=layer.Transceivers(uui).get_transceiver_range();

        idx_r=find(range<=r_max&range>=r_min);
        
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
              
        [Sv_f_temp,f_vec_temp,~,~]=layer.Transceivers(uui).sv_f_from_region(region_cl('Idx_pings',idx_pings,'Idx_r',idx_r),'envdata',layer.EnvData,'cal',cal,'cal_eba',cal_eba);
        Sv_f_temp_mean=10*log10(nanmean(nanmean(10.^(Sv_f_temp/10))));
        Sv_f_temp_mean=permute(Sv_f_temp_mean,[2 3 1]);
        Sv_f=[Sv_f Sv_f_temp_mean];
        f_vec=[f_vec f_vec_temp];
        
        
        
        clear f_vec_temp Sv_f_temp
    else
        fprintf('%s not in  FM mode\n',layer.Transceivers(uui).Config.ChannelID);
        
        f_vec_temp=layer.Frequencies(uui);
        
        range=layer.Transceivers(uui).get_transceiver_range();

        idx_r=find(range<=r_max&range>=r_min);
             
        field='sv';
        if ismember('svdenoised',layer.Transceivers(uui).Data.Fieldname)
           field='svdenoised';
        end
        
        [Sv,~,~,bad_data_mask,bad_trans_vec,~,below_bot_mask,~]=layer.Transceivers(uui).get_data_from_region(region_cl('Idx_pings',idx_pings,'Idx_r',idx_r),...
            'field',field);
        Sv(bad_data_mask|below_bot_mask)=nan;
        Sv(:,bad_trans_vec)=nan;
        
        Sv_f=[Sv_f 10*log10(nanmean(10.^(Sv(:)/10)))];
        
        f_vec=[f_vec f_vec_temp];
        clear f_vec_temp
    end
end

[f_vec,idx_sort]=sort(f_vec);
Sv_f=Sv_f(idx_sort);

hfig=new_echo_figure(main_figure,'Name','SV(f)','Tag','sv_freq','Keep_old',1);
%subplot(1,3,uui)
%plot(f_vec/1e3,Sv_f,'b','linewidth',0.2);
ah=axes(hfig);
plot(ah,f_vec/1e3,Sv_f,'r','linewidth',2)
%plot(f_vec/1e3,10*log10(filter2_perso(ones(1,nanmin(10,length(f_vec))),10.^(Sv_f_mean/10))),'k','linewidth',2)
grid on;
xlabel('kHz')
ylabel('Sv(dB)')

clear Sv_f f_vec
end