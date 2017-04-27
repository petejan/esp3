function Sv_freq_response_func(main_figure,idx_r,idx_pings)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
range=layer.Transceivers(idx_freq).get_transceiver_range();

r_min=nanmin(range(idx_r));
r_max=nanmax(range(idx_r));


f_vec=[];
Sv_f=[];

[cal_path,~,~]=fileparts(layer.Filename{1});


for uui=1:length(layer.Frequencies)
    if strcmp(layer.Transceivers(uui).Mode,'FM')
        file_cal=fullfile(cal_path,['Curve_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
        
        file_cal_eba=fullfile(cal_path,[ 'Curve_EBA_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
        range=layer.Transceivers(idx_freq).get_transceiver_range();
        range(range<r_min)=[];
        range(range>r_max)=[];
        
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
        
        

        
        [~,f_vec_temp,~]=layer.Transceivers(uui).processSv_f_r_2(layer.EnvData,idx_pings(1),range,[],cal,cal_eba);
        Sv_f_temp=nan(length(f_vec_temp),length(idx_pings));
        
        for kk=1:length(idx_pings)
            [sv_temp,~,~]=layer.Transceivers(uui).processSv_f_r_2(layer.EnvData,idx_pings(kk),range,[],cal,cal_eba);
            Sv_f_temp(:,kk)=10*log10(nanmean(10.^(sv_temp/10),1));
        end
        
        
        Sv_f=[Sv_f 10*log10(nanmean(10.^(Sv_f_temp'/10)))];
        f_vec=[f_vec f_vec_temp];
        
        
        [Sv_f_temp_2,f_vec_temp_2,~,~]=layer.Transceivers(uui).sv_f_from_region(region_cl('Idx_pings',idx_pings,'Idx_r',idx_r),'envdata',layer.EnvData,'cal',cal,'cal_eba',cal_eba);
        
        Sv_f_2=[Sv_f 10*log10(nanmean(10.^(Sv_f_temp_2'/10)))];
        f_vec_2=[f_vec_2 f_vec_temp_2];
        
        clear f_vec_temp Sv_f_temp
    else
        fprintf('%s not in  FM mode\n',layer.Transceivers(uui).Config.ChannelID);
        
        f_vec_temp=layer.Frequencies(uui);
        
        Sv=layer.Transceivers(uui).Data.get_datamat('Sv');
        
        range=layer.Transceivers(uui).get_transceiver_range();
        [nb_samples,~]=size(Sv);
        
        [~,idx_r1]=nanmin(abs(range-r_min));
        [~,idx_r2]=nanmin(abs(range-r_max));
        
        idx_r1=nanmax(idx_r1,1);
        idx_r2=nanmin(idx_r2,nb_samples);
        Sv_f=[Sv_f 10*log10(nanmean(nanmean(10.^(Sv(idx_r1:idx_r2,idx_pings)/10))))];
        
        f_vec=[f_vec f_vec_temp];
        clear f_vec_temp
    end
end


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