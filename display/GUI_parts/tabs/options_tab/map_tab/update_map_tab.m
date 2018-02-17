function update_map_tab(main_figure,varargin)

p = inputParser;
addRequired(p,'main_figure',@(obj) isa(obj,'matlab.ui.Figure'));
addParameter(p,'map',1,@isnumeric);
addParameter(p,'st',0,@isnumeric);
addParameter(p,'histo',0,@isnumeric);

parse(p,main_figure,varargin{:});

map_tab_comp=getappdata(main_figure,'Map_tab');
layer=getappdata(main_figure,'Layer');

curr_disp=getappdata(main_figure,'Curr_disp');


if isempty(layer)
    return;
end

if p.Results.map
    %delete(get(map_tab_comp.ax,'children'));
    cla(map_tab_comp.ax);
    lat=layer.GPSData.Lat;
    long=layer.GPSData.Long;
    if ~isempty(lat)
        
        set(map_tab_comp.ax,'visible','on');
        LongLim=[nanmin(long) nanmax(long)];        
        LatLim=[nanmin(lat) nanmax(lat)];      
        
        [LatLim,LongLim]=ext_lat_lon_lim(LatLim,LongLim,0.3);     
        
        proj_i=init_proj('Mercator',LongLim,LatLim);
        
        if isempty(proj_i)
            return;
        end
        try
            m_grid('tickdir','in','axes',map_tab_comp.ax);
        catch
            set(map_tab_comp.ax,'visible','off');
            warning('area too small for ticks to display');
        end
        
        map_tab_comp.Proj=proj_i;
        map_tab_comp.LongLim=LongLim;
        map_tab_comp.LatLim=LatLim;
        
        map_tab_comp.tracks(1)=m_plot(map_tab_comp.ax,long(1),lat(1),'Marker','o','Markersize',10,'Color',[0 0.5 0],'tag','start');
        map_tab_comp.tracks(2)=m_plot(map_tab_comp.ax,long,lat,'Color','k','tag','Nav');
        
                       
    else
        set(map_tab_comp.ax,'visible','off');
    end
end

if p.Results.histo
    display_st_or_track_hist(main_figure,map_tab_comp.ax_hist,{'tracks','st'});
    cax=curr_disp.getCaxField('singletarget');
    xlim(map_tab_comp.ax_hist,cax);
end

if p.Results.st
    delete(map_tab_comp.ax_pos.Children);
    init_st_ax(main_figure,map_tab_comp.ax_pos)
    display_st_or_track_pos(main_figure,map_tab_comp.ax_pos,'st');
end

setappdata(main_figure,'Map_tab',map_tab_comp);

end