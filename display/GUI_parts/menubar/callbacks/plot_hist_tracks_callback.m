function plot_hist_tracks_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
curr_disp=getappdata(main_figure,'Curr_disp');


[idx_freq,found]=find_freq_idx(layer,curr_disp.Freq);
if found==0
    return;
end

Transceiver=layer.Transceivers(idx_freq);
tracks = Transceiver.Tracks;

if isempty(tracks)
    return;
end

ST = Transceiver.ST;
X_st=ST.Ping_number;
%R_st=ST.Target_range;
% R_st_min=ST.Target_range_min;
% R_st_max=ST.Target_range_max;
f_vec=layer.Frequencies;
[~,idx_sort]=sort(f_vec);

if isempty(tracks.target_id)
    return;
end

TS=nan(length(f_vec),length(tracks.target_id));

tag=cell(1,length(idx_sort));

for uui=idx_sort
    range_freq=layer.Transceivers(idx_freq).Data.get_range();
    tag{uui}=sprintf('Track from %.0f kHz',f_vec(uui)/1e3);
    Sp=layer.Transceivers(uui).Data.get_datamat('sp');
    AcrossAngle=layer.Transceivers(uui).Data.get_datamat('acrossangle');
    AlongAngle=layer.Transceivers(uui).Data.get_datamat('alongangle');
    BeamWidthAlongship=layer.Transceivers(uui).Config.BeamWidthAlongship;
    BeamWidthAthwartship=layer.Transceivers(uui).Config.BeamWidthAthwartship;
    Comp=simradBeamCompensation(BeamWidthAlongship,BeamWidthAthwartship,AcrossAngle,AlongAngle);
    Comp(Comp>12)=nan;
    range=layer.Transceivers(uui).Data.get_range();
    
    [nb_samples,~]=size(Sp);
    
    for k=1:length(tracks.target_id)
        idx_targets=tracks.target_id{k};
        idx_pings=X_st(idx_targets);
        if uui==idx_freq
            idx_lin=ST.idx_r(idx_targets)+(idx_pings-1)*nb_samples;
        else
            idx_r=nan(size(idx_pings));
            
            for ik=1:length(idx_targets)
                [~,idx_r(ik)]=nanmin(abs(range-range_freq(ST.idx_r(idx_targets(ik)))));
            end
            idx_lin=idx_r+(idx_pings-1)*nb_samples;
        end
        
        
        
        Sp_temp=Sp(idx_lin);
        Comp_temp=Comp(idx_lin);
        
        
        %         idx_r_min=nan(size(idx_pings));
        %         idx_r_max=nan(size(idx_pings));
        %          Sp_temp=nan(size(idx_pings));
        %         Comp_temp=nan(size(idx_pings));
        %         for ik=1:length(idx_targets)
        %             [~,idx_r_min(ik)]=nanmin(abs(range-R_st_min(idx_targets(ik))));
        %             [~,idx_r_max(ik)]=nanmin(abs(range-R_st_max(idx_targets(ik))));
        %             [Sp_temp(ik),id_comp]=nanmax(Sp(idx_r_min(ik):idx_r_max(ik),idx_pings(ik)));
        %             Comp_temp(ik)=Comp(idx_r_min(ik)+id_comp-1,idx_pings(ik));
        %         end
        
        TS_f_temp=Sp_temp+Comp_temp;
        TS(uui,k)=10*log10(nanmean(10.^(TS_f_temp/10)));
    end
end


for k=1:size(TS,1)
    [pdf_temp,x_temp]=pdf_perso(TS(k,:),'bin',25);
    new_echo_figure(main_figure);
    bar(x_temp,pdf_temp);
    xlabel('TS(dB)');
    ylabel('Pdf');
    title(tag{k});
    grid on;

end


setappdata(main_figure,'Layer',layer);

end