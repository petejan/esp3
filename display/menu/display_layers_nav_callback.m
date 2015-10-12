function display_layers_nav_callback(~,~,main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
layers=getappdata(main_figure,'Layers');

hfig=figure();

lat_lim=[nan nan];
lon_lim=[nan nan];
eint_echo=zeros(1,length(layers));
eint_esp2=zeros(1,length(layers));
idx_freq=1;
sw_s=100;

for i=1:length(layers)
    
    lat{i}=layers(i).GPSData.Lat;
    lon{i}=layers(i).GPSData.Long;
    
    if ~isempty(layers(i).SurveyData)
        if ischar(layers(i).SurveyData.Stratum)
            str{i}=sprintf('%s\n Snapshot %d\n Stratum %s\n Transect %d\n',...
                layers(i).Filename{1},layers(i).SurveyData.Snapshot,layers(i).SurveyData.Stratum,layers(i).SurveyData.Transect);
        else
            str{i}=sprintf('%s\n Snapshot %d\n Stratum %d\n Transect %d\n',...
                layers(i).Filename{1},layers(i).SurveyData.Snapshot,layers(i).SurveyData.Stratum,layers(i).SurveyData.Transect);
        end
    else
        str{i}=layers(i).Filename{1};
    end
    
    idx_echo=layers(i).Transceivers(idx_freq).list_regions_origin('saved');
    idx_esp2=layers(i).Transceivers(idx_freq).list_regions_origin('esp2');
    
    reg_echo=layers(i).Transceivers(idx_freq).get_reg_spec(idx_echo);
    reg_esp2=layers(i).Transceivers(idx_freq).get_reg_spec(idx_esp2);

    output_echo(i)=layers(i).Transceivers(idx_freq).slice_transect('reg',reg_echo,'Slice_w',sw_s,'Slice_units','pings');
    output_esp2(i)=layers(i).Transceivers(idx_freq).slice_transect('reg',reg_esp2,'Slice_w',sw_s,'Slice_units','pings');
    
    lat_lim(1)=nanmin(lat_lim(1),nanmin(lat{i}));
    lon_lim(1)=nanmin(lon_lim(1),nanmin(lon{i}));
    
    lat_lim(2)=nanmax(lat_lim(2),nanmax(lat{i}));
    lon_lim(2)=nanmax(lon_lim(2),nanmax(lon{i}));
    
end
abscf_max=1e-3;

if ~isempty(lon)
    m_proj('UTM','long',[lon_lim(1)-0.01 lon_lim(2)+0.01],'lat',[lat_lim(1)-0.01 lat_lim(2)+0.01]);
    hold on;
    m_grid('box','fancy','tickdir','in');
    
    for uui=1:length(lon)
        u_plot(uui)=m_plot(lon{uui},lat{uui},'g');
        set(u_plot(uui),'ButtonDownFcn',{@disp_line_name_callback,str{uui}});       
        for uuj=1:output_echo(uui).num_slices
            m_plot(output_echo(uui).slice_lon(uuj),output_echo(uui).slice_lat(uuj),'.k','markersize',6);
            m_range_ring(output_echo(uui).slice_lon(uuj),output_echo(uui).slice_lat(uuj),sqrt(output_echo(uui).slice_abscf(uuj)/abscf_max),'color','b');
        end
        for uuj=1:output_esp2(uui).num_slices
            m_plot(output_esp2(uui).slice_lon(uuj),output_esp2(uui).slice_lat(uuj),'.k','markersize',6);
            m_range_ring(output_esp2(uui).slice_lon(uuj),output_esp2(uui).slice_lat(uuj),sqrt(output_esp2(uui).slice_abscf(uuj)/abscf_max),'color','r');
        end
    end
    try
        m_gshhs_h('color','k')
    catch
        disp('No Geographical data available...')
    end
else
    close(hfig);
    warning('No navigation data');

end


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
