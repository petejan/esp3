function update_map_tab(main_figure)

map_tab_comp=getappdata(main_figure,'Map_tab');
layer=getappdata(main_figure,'Layer');
    
curr_disp=getappdata(main_figure,'Curr_disp');


if isempty(layer)
    return;
end
delete(get(map_tab_comp.ax,'children'));

lat=layer.GPSData.Lat;
long=layer.GPSData.Long;
if isempty(lat)
    return;
end

LongLim=[nanmin(long) nanmax(long)];

LatLim=[nanmin(lat) nanmax(lat)];

[LatLimExt,LongLimExt]=ext_lat_lon_lim(LatLim,LongLim,0.3);

list_proj=m_getproj;
proj={list_proj(:).name};
proj_i=curr_disp.Proj;
sucess=0;
i=0;
while sucess==0&&i<length(proj)
    try
        m_proj(proj_i,'long',LongLimExt,'lat',LatLimExt);
        sucess=1;
    catch
        i=i+1;        
        fprintf(1,'Can''t use %s projection inside this area... Trying %s\n',proj_i,proj{i});
        proj_i=proj{i};
        if i==length(proj)
            fprintf(1,'Could not find any appropriate projection\n');
            return;
        end
    end
end
curr_disp.Proj=proj_i;
map_tab_comp.Proj=proj_i;
map_tab_comp.LongLim=LongLim;
map_tab_comp.LatLim=LatLim;
map_tab_comp.tracks(1)=m_plot(map_tab_comp.ax,long(1),lat(1),'Marker','o','Markersize',10,'Color',[0 0.5 0],'tag','start');
map_tab_comp.tracks(2)=m_plot(map_tab_comp.ax,long,lat,'Color','k','tag','Nav');
try
    m_grid('tickdir','in','axes',map_tab_comp.ax);
catch
    warning('area too small for ticks to display')
end

setappdata(main_figure,'Map_tab',map_tab_comp);
setappdata(main_figure,'Curr_disp',curr_disp);


end