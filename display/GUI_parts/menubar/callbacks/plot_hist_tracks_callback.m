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

if isempty(tracks.target_id)
    return;
end

tag=sprintf('Track from %.0f kHz',curr_disp.Freq/1e3);
TS=[];
for k=1:length(tracks.target_id)
    idx_targets=tracks.target_id{k};
    TS=[TS ST.TS_comp(idx_targets)];    
end


[pdf_temp,x_temp]=pdf_perso(TS,'bin',25);
hfig=figure();
bar(x_temp,pdf_temp);
xlabel('TS(dB)');
ylabel('Pdf');
title(tag);
grid on;
new_echo_figure(main_figure,'fig_handle',hfig);


setappdata(main_figure,'Layer',layer);

end