function Sv_freq_response_func(main_figure,idx_r,idx_pings)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
range=layer.Transceivers(idx_freq).Data.get_range();

r_min=nanmin(range(idx_r));
r_max=nanmax(range(idx_r));


f_vec=[];
Sv_f=[];

[cal_path,~,~]=fileparts(layer.Filename{1});


for uui=1:length(layer.Frequencies)
    if strcmp(layer.Transceivers(uui).Mode,'FM')
        file_cal=fullfile(cal_path,['Curve_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
                
        file_cal_eba=fullfile(cal_path,[ 'Curve_EBA_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
        range=layer.Transceivers(idx_freq).Data.get_range();
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
        
          
%         for kk=1:length(idx_pings)
%             [Sv_f_temp(:,kk),f_vec_temp(:,kk)]=processSv_f_r(layer.Transceivers(uui),layer.EnvData,idx_pings(kk),range(1),range(end),cal,cal_eba,[]);
%            
%         end

        for kk=1:length(idx_pings)
            [sv_temp,f_vec_t,~]=processSv_f_r_2(layer.Transceivers(uui),layer.EnvData,idx_pings(kk),range,[],cal,cal_eba);
            Sv_f_temp(:,kk)=10*log10(nanmean(10.^(sv_temp/10),1));
            f_vec_temp(:,kk)=nanmean(f_vec_t,1);
        end
        
        Sv_f=[Sv_f 10*log10(nanmean(10.^(Sv_f_temp'/10)))];     
        f_vec=[f_vec f_vec_temp(:,1)'];
        
        
        
        clear f_vec_temp Sv_f_temp
    else
        fprintf('%s not in  FM mode\n',layer.Transceivers(uui).Config.ChannelID);
        
        f_vec_temp=layer.Frequencies(uui);
        
        Sv=layer.Transceivers(uui).Data.get_datamat('Sv');
        
        range=layer.Transceivers(uui).Data.get_range();
        [nb_samples,~]=size(Sv);

        [~,idx_r1]=nanmin(abs(range-range(1)));
        [~,idx_r2]=nanmin(abs(range-range(2)));
      
        idx_r1=nanmax(idx_r1,1);
        idx_r2=nanmin(idx_r2,nb_samples);
        Sv_f=[Sv_f 10*log10(nanmean(nanmean(10.^(Sv(idx_r1:idx_r2,idx_pings)/10))))];
        
        f_vec=[f_vec f_vec_temp];
        clear f_vec_temp
    end
end


hfig=new_echo_figure(main_figure,'Name','SV(f)','Tag','sv_freq');
%subplot(1,3,uui)
%plot(f_vec/1e3,Sv_f,'b','linewidth',0.2);
hold on;
plot(f_vec/1e3,Sv_f,'r','linewidth',2)
%plot(f_vec/1e3,10*log10(filter2_perso(ones(1,nanmin(10,length(f_vec))),10.^(Sv_f_mean/10))),'k','linewidth',2)
grid on;
xlabel('kHz')
ylabel('Sv(dB)')

clear Sv_f f_vec
end