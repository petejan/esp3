function display_layers_nav_callback(~,~,main_figure)
hfigs=getappdata(main_figure,'ExternalFigures');
layers=getappdata(main_figure,'Layers');

lat_lim=[nan nan];
lon_lim=[nan nan];
snapshot=zeros(1,length(layers));

idx_freq=1;
sw_s=250;

for i=1:length(layers)
    
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
    end
    %idx_echo=layers(i).Transceivers(idx_freq).list_regions_origin('saved');
    %idx_esp2=layers(i).Transceivers(idx_freq).list_regions_origin('esp2');
    idx_esp2=1:length(layers(i).Transceivers(idx_freq).Regions);
    %reg_echo=layers(i).Transceivers(idx_freq).get_reg_spec(idx_echo);
    reg_esp2=layers(i).Transceivers(idx_freq).get_reg_spec(idx_esp2);
    
    %output_echo(i)=layers(i).Transceivers(idx_freq).slice_transect('reg',reg_echo,'Slice_w',sw_s,'Slice_units','pings');
    output_esp2(i)=layers(i).Transceivers(idx_freq).slice_transect('reg',reg_esp2,'Slice_w',sw_s,'Slice_units','pings');
    
    lat_lim(1)=nanmin(lat_lim(1),nanmin(lat{i}));
    lon_lim(1)=nanmin(lon_lim(1),nanmin(lon{i}));
    
    lat_lim(2)=nanmax(lat_lim(2),nanmax(lat{i}));
    lon_lim(2)=nanmax(lon_lim(2),nanmax(lon{i}));
    
end
abscf_max=1e-3;
snap=unique(snapshot);


for usnap=1:length(snap)
    idx_snap=find(snapshot==snap(usnap));
    hfig(usnap)=figure();
    m_proj('UTM','long',[lon_lim(1)-0.01 lon_lim(2)+0.01],'lat',[lat_lim(1)-0.01 lat_lim(2)+0.01]);
    hold on;
    title(sprintf('Snapshot %d',snap(usnap)));
    m_grid('box','fancy','tickdir','in');
    for uui=1:length(idx_snap)
        if ~isempty(lon{idx_snap(uui)})
            u_plot(idx_snap(uui))=m_plot(lon{idx_snap(uui)},lat{idx_snap(uui)},'g');
            %m_text(lon{idx_snap(uui)}(1),lat{idx_snap(uui)}(1),str_disp{idx_snap(uui)},'tag','name');
            set(u_plot(idx_snap(uui)),'ButtonDownFcn',{@disp_line_name_callback,str{idx_snap(uui)}});
            %             for uuj=1:output_echo(idx_snap(uui)).num_slices
            %                 m_plot(output_echo(idx_snap(uui)).slice_lon(uuj),output_echo(idx_snap(uui)).slice_lat(uuj),'.k','markersize',6);
            %                 m_range_ring(output_echo(idx_snap(uui)).slice_lon(uuj),output_echo(idx_snap(uui)).slice_lat(uuj),sqrt(output_echo(idx_snap(uui)).slice_abscf(uuj)/abscf_max),'color','b');
            %             end
            for uuj=1:output_esp2(idx_snap(uui)).num_slices
                m_plot(output_esp2(idx_snap(uui)).slice_lon(uuj),output_esp2(idx_snap(uui)).slice_lat(uuj),'.k','markersize',6);
                m_range_ring(output_esp2(idx_snap(uui)).slice_lon(uuj),output_esp2(idx_snap(uui)).slice_lat(uuj),sqrt(output_esp2(idx_snap(uui)).slice_abscf(uuj)/abscf_max),'color','r');
            end
        end
    end
    try
      m_gshhs_h('patch',[.5 .5 .5],'edgecolor','k');
    catch
        disp('No Geographical data available...')
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
