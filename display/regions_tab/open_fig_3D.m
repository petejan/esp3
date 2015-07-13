function open_fig_3D(main_figure,TS,Sv,lat_t,lon_t,N_t,E_t,Z_t,Mask)



curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

idx_freq=find_freq_idx(layer,curr_disp.Freq);

depth_bottom=layer.Transceivers(idx_freq).Bottom.Range;
angle_beam=1/2*(layer.Transceivers(idx_freq).Config.BeamWidthAlongship+layer.Transceivers(idx_freq).Config.BeamWidthAthwartship);


[nb_samples,nb_pings]=size(Mask);
range=layer.Transceivers(idx_freq).Data.Range;
footprint_radio=double(repmat(depth_bottom,nb_samples,1)*tan(angle_beam*pi/180));

pings=repmat(layer.Transceivers(idx_freq).Data.Number,nb_samples,1);
times=repmat(layer.Transceivers(idx_freq).Data.Time,nb_samples,1);
times_vec=datevec(times);



idx=find(Mask);

new_fig=figure('Visible','on',...
    'Units','pixels','Position',[100 100 720 640],...       %Position and size normalized to the screen size ([left, bottom, width, height])
    'Color','White',...                                         %Background color
    'Name','Flare Editor','NumberTitle','off',...    %GUI Name
    'Resize','off');

movegui(new_fig,'center')
ax=axes('units','pixel','position',[100 100 500 500]);
title('Flare TS Echoes(dB)')
hold on;
h=scatter3(lat_t(:),lon_t(:),-Z_t(:),8,TS(:),'filled');
xlabel('Lat (deg)','fontsize',16)
ylabel('Long (deg)','fontsize',16)
zlabel('Depth (m)')
set(gca,'fontsize',16);
colormap jet;
grid on;
axis square
%set(gca,'DataAspectRatio',[1,1,.3]);
view(3)
colorbar('units','pixel','position',[640 200 25 400]);

handles=guihandles(new_fig);
handles.SoundVelocity=layer.EnvData.SoundSpeed;
handles.freq_echo=layer.Frequencies(idx_freq);
handles.SampleInterval=layer.Transceivers(idx_freq).Params.SampleInterval(1);


handles.ping_filt=pings(idx);
handles.Eping_filt=E_t;
handles.Nping_filt=N_t;
handles.foot_radio_filt=footprint_radio(idx);
handles.hour_filt=times_vec(idx,4);
handles.min_filt=times_vec(idx,5);
handles.sec_filt=times_vec(idx,6);
handles.rawname=layer.Filename;
handles.ax=ax;
handles.h=h;
handles.n_div=60;
handles.TS2aver=TS(:);
handles.Sv2aver=Sv(:);
handles.latd2aver=lat_t(:);
handles.longd2aver=lon_t(:);
handles.znew2aver=Z_t(:);

uicontrol(new_fig,'Style','Text','units','pixel','pos',[600 110 40 40],'string','n','BackgroundColor','white','fontsize',16);
handles.n_box=uicontrol(new_fig,'Style','Edit','units','pixel','pos',[640 110 40 40],'string',num2str(handles.n_div,'%.0f'),'BackgroundColor','white','callback',@set_n_div);
uicontrol(new_fig,'Style','pushbutton','String','Spine','units','pixel','pos',[550 65 75 40],'callback',@spine_callback);
uicontrol(new_fig,'Style','pushbutton','String','Save Spine','units','pixel','pos',[625 65 75 40],'callback',@save_spine_callback);
uicontrol(new_fig,'Style','pushbutton','String','Save Data','units','pixel','pos',[550 25 150 40],'callback',@save_edition_Callback);

guidata(new_fig,handles);

end

function spine_callback(hObj,~,~)

handles=guidata(hObj);

if isfield(handles,'spine_plot')
    delete(handles.spine_plot);
end

[handles.Lat_spine,handles.Long_spine,handles.depth_mean,...
    handles.N_Geo_mean, handles.E_Geo_mean,handles.Zone_Geo_mean,handles.TSdB_mean,...
    handles.SvdB_mean]=spine(handles.h,...
    handles.n_div,handles.TS2aver,handles.Sv2aver,handles.latd2aver,...
    handles.longd2aver,handles.znew2aver);
handles.output=hObj;


axes(handles.ax);
handles.spine_plot=plot3(handles.Lat_spine,handles.Long_spine,handles.depth_mean,'Marker','o','MarkerFaceColor','Green');
grid on;
xlabel('Latitude')
ylabel('Longitude')
zlabel('Depth (meters)')
title('"Flare Spine"')

guidata(hObj,handles);


end
function save_spine_callback(hObj,~,~)

handles=guidata(hObj);
savingspine(handles.rawname,-handles.depth_mean, handles.N_Geo_mean, handles.E_Geo_mean,...
    handles.Zone_Geo_mean,handles.TSdB_mean,...
    handles.SvdB_mean,handles.Lat_spine,handles.Long_spine)

end


function save_edition_Callback(hObj, ~, ~)

handles=guidata(hObj);

savingdata(handles.h,handles.rawname,handles.TS2aver,handles.Sv2aver,...
    handles.latd2aver,handles.longd2aver,handles.znew2aver,handles.ping_filt,...
    handles.Eping_filt,handles.Nping_filt,...
    handles.foot_radio_filt,handles.SoundVelocity,handles.freq_echo,...
    handles.sampleinterval,...
    handles.hour_filt,handles.min_filt,handles.sec_filt);
handles.output=hObj;


end

function set_n_div(hObj, ~, ~)

handles=guidata(hObj);
n=str2double(get(handles.n_box,'string'));

if n>0&&n<1000
    handles.n_div=n;
else
    set(handles.n_box,'string',num2str(handles.n_div,'%.0f'));
end
handles.output=hObj;
guidata(hObj,handles);
end

