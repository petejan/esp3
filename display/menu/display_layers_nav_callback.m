function display_layers_nav_callback(~,~,main_figure)
hfigs=getappdata(main_figure,'ExternalFigures');
layers=getappdata(main_figure,'Layers');
curr_disp=getappdata(main_figure,'Curr_disp');


snapshot=zeros(1,length(layers));
voyage=cell(1,length(layers));
lat=cell(1,length(layers));
lon=cell(1,length(layers));
str=cell(1,length(layers));
str_disp=cell(1,length(layers));


for i=1:length(layers)
    idx_freq=find_freq_idx(layers(i),curr_disp.Freq);
    lat{i}=layers(i).GPSData.Lat;
    lon{i}=layers(i).GPSData.Long;
    
    if ~isempty(layers(i).SurveyData)
        if ischar(layers(i).SurveyData.Stratum)
            str{i}=sprintf('File %s\n Stratum %s\n Transect %d\n',...
                layers(i).Filename{1},layers(i).SurveyData.Stratum,layers(i).SurveyData.Transect);
            str_disp{i}=sprintf('St %s T %d',...
                layers(i).SurveyData.Stratum,layers(i).SurveyData.Transect);
        else
            str{i}=sprintf('File %s\n Stratum %d\n Transect %d\n',...
                layers(i).Filename{1},layers(i).SurveyData.Stratum,layers(i).SurveyData.Transect);
            str_disp{i}=sprintf('St %d T %d',...
                layers(i).SurveyData.Stratum,layers(i).SurveyData.Transect);
        end
    else
        str_disp{i}='';
        str{i}=layers(i).Filename{1};
    end
    if ~isempty(layers(i).SurveyData)
        snapshot(i)=layers(i).SurveyData.Snapshot;
        voyage{i}=layers(i).SurveyData.Voyage;
    else
        voyage{i}='';
    end
    
    %idx_esp2=layers(i).Transceivers(idx_freq).list_regions_origin('esp2');
    idx_reg=1:length(layers(i).Transceivers(idx_freq).Regions);
    reg=layers(i).Transceivers(idx_freq).get_reg_spec(idx_reg);
    sw_s=layers(i).SurveyData.VerticalSlice;
    output(i)=layers(i).Transceivers(idx_freq).slice_transect('reg',reg,'Slice_w',sw_s,'Slice_units','pings');
    %voyage{i}='CS2015';
    
end

trip=unique(lower(voyage));

lat_lim=cell(1,length(trip));
lon_lim=cell(1,length(trip));

for u=1:length(trip)
    lat_lim{u}=[nan nan];
    lon_lim{u}=[nan nan];
    utrip=find(strcmpi(trip{u},voyage));
    for ut=1:length(utrip)
        lat_lim{u}(1)=nanmin(lat_lim{u}(1),nanmin(lat{utrip(ut)}));
        lon_lim{u}(1)=nanmin(lon_lim{u}(1),nanmin(lon{utrip(ut)}));
        lat_lim{u}(2)=nanmax(lat_lim{u}(2),nanmax(lat{utrip(ut)}));
        lon_lim{u}(2)=nanmax(lon_lim{u}(2),nanmax(lon{utrip(ut)}));
    end
end

abscf_max=1e-3;


for u=1:length(trip)
    utrip=find(strcmpi(trip{u},voyage));
    snap=unique(snapshot(utrip));
    hfig(u)=figure();
    nb_row=ceil(length(snap)/3);
    nb_col=nanmin(length(snap),3);
    for usnap=1:length(snap)
        idx_snap=find(snapshot(utrip)==snap(usnap));
        figure(hfig(u));
        subplot(nb_row,nb_col,usnap);
        m_proj('lambert','long',[lon_lim{u}(1)-0.01 lon_lim{u}(2)+0.01],'lat',[lat_lim{u}(1)-0.01 lat_lim{u}(2)+0.01]);
        hold on;
        title(sprintf('%s\n Snapshot %d',voyage{utrip(1)},snap(usnap)));
        m_grid('box','fancy','tickdir','in');
        for uui=1:length(idx_snap)
            if ~isempty(lon{utrip(idx_snap(uui))})
                u_plot(utrip(idx_snap(uui)))=m_plot(lon{utrip(idx_snap(uui))},lat{utrip(idx_snap(uui))},'k');
                set(u_plot(utrip(idx_snap(uui))),'ButtonDownFcn',{@disp_line_name_callback,str{utrip(idx_snap(uui))}});
                ring_size=sqrt(output(utrip(idx_snap(uui))).slice_abscf/abscf_max);
                %ring_size=10*log10(output(utrip(idx_snap(uui))).slice_abscf/abscf_max);
                %m_plot(output(utrip(idx_snap(uui))).slice_lon,output(utrip(idx_snap(uui))).slice_lat,'.k','markersize',2);
                idx_rings=find(ring_size>0);
                for uuj=idx_rings      
                    m_range_ring(output(utrip(idx_snap(uui))).slice_lon(uuj),output(utrip(idx_snap(uui))).slice_lat(uuj),ring_size(uuj),'color','r');
                end
            end
        end
        try
            m_gshhs_h('patch',[.5 .5 .5],'edgecolor','k');
        catch
            disp('No Geographical data available...')
        end        
    end
end

hfigs_new=[hfigs hfig];
setappdata(main_figure,'ExternalFigures',hfigs_new);

end



function disp_line_name_callback(src,~,name)

ax=get(src,'parent');
cp=ax.CurrentPoint;
x = cp(1,1);
y=cp(1,2);

u=get(ax,'children');

for ii=1:length(u)
    if strcmp(get(u(ii),'tag'),'name')
        delete(u(ii));
    end
end
axes(ax);
text(x,y,name,'tag','name');


end
