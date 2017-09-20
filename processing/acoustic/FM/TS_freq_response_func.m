function TS_freq_response_func(main_figure,idx_r,idx_pings)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');

ah=axes_panel_comp.main_axes;
clear_lines(ah);
idx_freq=find_freq_idx(layer,curr_disp.Freq);
range=layer.Transceivers(idx_freq).get_transceiver_range();

r_min=nanmin(range(idx_r));
r_max=nanmax(range(idx_r));

f_vec_save=[];

TS_f=[];

[cal_path,~,~]=fileparts(layer.Filename{1});

[~,idx_sort]=sort(layer.Frequencies);

leg_fig=cell(1,length(idx_sort));
i_leg=1;

for uui=idx_sort
    leg_fig{i_leg}=sprintf('%.0f kHz',layer.Frequencies(uui)/1000);
    i_leg=i_leg+1;
    range=layer.Transceivers(uui).get_transceiver_range();
    idx_r=find(range<=r_max&range>=r_min);
    
    if isempty(idx_r)
        [~,idx_r]=nanmin(abs(range-r_max));
    end
    
    
    Sp=layer.Transceivers(uui).Data.get_datamat('sp');


    Sp_red=Sp(idx_r,idx_pings);
    
    [Sp_max,idx_peak]=nanmax(Sp_red,[],1);
    idx_peak=idx_peak+idx_r(1)-1;

    
    if strcmp(layer.Transceivers(uui).Mode,'FM')
        
        file_cal=fullfile(cal_path,['Curve_' num2str(layer.Frequencies(uui),'%.0f') '.mat']);
        
        if exist(file_cal,'file')>0
            cal=load(file_cal);
            disp('Calibration file loaded.');
        else
            disp('No calibration file');
            cal=[];
        end
                
         set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',length(idx_pings), 'Value',0);
        load_bar_comp.status_bar.setText(sprintf('Processing TS estimation Frequency %.0fkz',layer.Transceivers(uui).Params.Frequency(1)/1e3));

        
        for kk=1:length(idx_pings)
            [Sp_f(:,kk),Compensation_f(:,kk),f_vec(:,kk)]=processTS_f_v2(layer.Transceivers(uui),layer.EnvData,idx_pings(kk),range(idx_peak(kk)),1,cal,[]);
            set(load_bar_comp.progress_bar,'Value',kk);
        end
        
        Compensation_f(Compensation_f>6)=nan;
        TS_f=[TS_f; Sp_f+Compensation_f];
        
        f_vec_save=[f_vec_save; f_vec(:,1)];
        
        
        clear Sp_f Compensation_f  f_vec
    else
        fprintf('%s not in  FM mode\n',layer.Transceivers(uui).Config.ChannelID);
        f_vec_save=[f_vec_save;layer.Frequencies(uui)];
        
        AlongAngle=layer.Transceivers(uui).Data.get_datamat('AlongAngle');
        AcrossAngle=layer.Transceivers(uui).Data.get_datamat('AcrossAngle');
        
        BeamWidthAlongship=layer.Transceivers(uui).Config.BeamWidthAlongship;
        BeamWidthAthwartship=layer.Transceivers(uui).Config.BeamWidthAthwartship;
        
        comp=simradBeamCompensation(BeamWidthAlongship,BeamWidthAthwartship , AcrossAngle((idx_pings-1)*length(range)+idx_peak), AlongAngle((idx_pings-1)*length(range)+idx_peak));
        comp(comp>12|comp<0)=nan;
        TS_f=[TS_f; Sp_max+comp;];
    end
end




if ~isempty(f_vec_save)
    
    %     f_vec_2=f_vec_save(1):1000:f_vec_save(end);
    %     ts=nan(1,length(f_vec_2));
    %
    %
    %     for jj=1:length(f_vec_2)
    %         ts(jj) = spherets(2*pi*f_vec_2(jj)/layer.EnvData.SoundSpeed, .0381/2, layer.EnvData.SoundSpeed, 6853, 4171, 1025, 14900);
    %     end
    %
    TS_f_mean=10*log10(nanmean(10.^(TS_f'/10)));
    [f_vec_save,idx_sort]=sort(f_vec_save);
    TS_f_mean=TS_f_mean(idx_sort);
    TS_f=TS_f(idx_sort,:);
    h=new_echo_figure(main_figure,'Name','TS Curve','Tag','ts_f_mean');
    ah=axes(h);
    plot(ah,f_vec_save/1e3,TS_f,'b','linewidth',0.2);
    hold on;
    plot(ah,f_vec_save/1e3,TS_f_mean,'r','linewidth',2)
    grid on;
    xlabel('kHz')
    ylabel('TS(dB)')
    
    choice = questdlg('Do you want to save this curve?', ...
        'Curve save',...
        'Yes','No', ...
        'Yes');
    % Handle response
    switch choice
        case 'Yes'
            
            choice_tag = questdlg('Do you want to think it is fish or krill?', ...
                'Identification',...
                'Fish','Krill','Neither', ...
                'Krill');
            curve=curve_cl('XData',f_vec_save,'YData',TS_f_mean,'Xunit','Hz','YUnit','TS(dB)','Tag',choice_tag);
            layer.add_curves(curve);
    end
    
    
    setappdata(main_figure,'Layer',layer);
    %     hold on;
    %     plot(f_vec_2/1e3,ts,'k','linewidth',2)
end
hide_status_bar(main_figure);
end
