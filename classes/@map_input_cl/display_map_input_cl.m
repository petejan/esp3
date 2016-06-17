function hfig=display_map_input_cl(obj,varargin)
p = inputParser;

addRequired(p,'obj',@(x) isa(x,'map_input_cl'));
addParameter(p,'hfig',[],@(h) isempty(h)|isa(h,'matlab.ui.Figure'));
addParameter(p,'main_figure',[],@(h) isempty(h)|isa(h,'matlab.ui.Figure'));
addParameter(p,'field','SliceAbscf',@ischar);
addParameter(p,'oneMap',0,@isnumeric);

parse(p,obj,varargin{:});
hfig=p.Results.hfig;
main_figure=p.Results.main_figure;
field=p.Results.field;


if isempty(hfig)
    hfig=figure();
end



%col_snap={'r','b','g','k','m'};
col_snap={'k'};

set(hfig,'Name','Navigation','NumberTitle','off','tag','nav');

LonLim=[nan nan];
LatLim=[nan nan];

snap=unique(obj.Snapshot);
LonLim(1)=nanmin(LonLim(1),obj.LonLim(1));
LonLim(2)=nanmax(LonLim(2),obj.LonLim(2));
LatLim(1)=nanmin(LatLim(1),obj.LatLim(1));
LatLim(2)=nanmax(LatLim(2),obj.LatLim(2));

if p.Results.oneMap>0
    snap=1;
end

nb_row=ceil(length(snap)/3);
nb_col=nanmin(length(snap),3);

n_ax=gobjects(length(snap),1);
figure(hfig);

for usnap=1:length(snap)
    n_ax(usnap)=subplot(nb_row,nb_col,usnap);
    proj=m_getproj;
    list_proj_str={proj(:).name};
    sucess=0;
    i=0;
    while sucess==0&&i<length(list_proj_str);
        try
            m_proj(obj.Proj,'long',LonLim,'lat',LatLim);
            sucess=1;
        catch
            i=i+1;
            fprintf(1,'Can''t use %s projection inside this area... Trying %s\n',obj.Proj,list_proj_str{i});
            obj.Proj=list_proj_str{i};
            if i==length(list_proj_str)
                fprintf(1,'Could not find any appropriate projection\n');
                close(hfig);
                return
            end
        end
    end
    axes(n_ax(usnap));
    hold on;
    
    try
        m_grid('box','fancy','tickdir','in');
    catch
        fprintf(1,'Area to small to display Navigation\n');
        close(hfig);
        return;
    end
    
    try
        if obj.Coast>0
            m_gshhs_h('patch',[.5 .5 .5],'edgecolor','k');
        end
    catch
        disp('No Geographical data available...')
    end
    
    if obj.Depth_Contour>0
        try
            [Cs,hs]=m_elev('contour',-10000:obj.Depth_Contour:-1,'edgecolor',[.4 .4 .4],'visible','on');
            clabel(Cs,hs,'fontsize',8);
        catch
            disp('No Bathymetric data available...')
        end
    end
end

u_plot=gobjects(1,length(obj.Snapshot));
u_plot_slice=gobjects(1,length(obj.Snapshot));

for usnap=1:length(snap)
    if p.Results.oneMap==0
        idx_snap=find(obj.Snapshot==snap(usnap));
        if isempty(idx_snap)
            continue;
        end
        axes(n_ax(usnap));
        hold on;
        title(sprintf('%s\n Snapshot %d',obj.Voyage{idx_snap(1)},snap(usnap)));
    else
        idx_snap=1:length(obj.Snapshot);
        axes(n_ax(usnap));
        hold on;
        title(sprintf('%s\n',obj.Voyage{idx_snap(1)}));
    end
    
    for uui=1:length(idx_snap)
        if ~isempty(obj.Lon{idx_snap(uui)})
            u_plot(idx_snap(uui))=m_plot(obj.Lon{idx_snap(uui)},obj.Lat{idx_snap(uui)},'color','b','linewidth',2,'Tag','Nav');
            set(u_plot(idx_snap(uui)),'ButtonDownFcn',{@disp_line_name_callback,hfig,idx_snap(uui)});
            m_plot(obj.Lon{idx_snap(uui)}(1),obj.Lat{idx_snap(uui)}(1),'Marker','>','Markersize',10,'Color','g','tag','start');
            if~isempty(main_figure)
                create_context_menu_track(main_figure,hfig,u_plot(idx_snap(uui)));
            end
        end
        
        if ~isempty(obj.SliceLon{idx_snap(uui)})
            if isempty(obj.Lon{idx_snap(uui)})
                m_plot(obj.SliceLon{idx_snap(uui)}(1),obj.SliceLat{idx_snap(uui)}(1),'Marker','>','Markersize',10,'Color','g','tag','start');
            end
            u_plot_slice(idx_snap(uui))=m_plot(obj.SliceLon{idx_snap(uui)},obj.SliceLat{idx_snap(uui)},'xk','Tag','Nav');
            set(u_plot_slice(idx_snap(uui)),'ButtonDownFcn',{@disp_line_name_callback,hfig,idx_snap(uui)});
            
            ring_size=obj.Rmax*sqrt(obj.(field){idx_snap(uui)}/obj.ValMax);
            idx_rings=find(ring_size>0);
            for uuj=idx_rings
                m_range_ring(obj.SliceLon{idx_snap(uui)}(uuj),obj.SliceLat{idx_snap(uui)}(uuj),ring_size(uuj),'color',col_snap{rem(usnap,length(col_snap))+1},'linewidth',1.5);
            end
            
            if~isempty(main_figure)
                create_context_menu_track(main_figure,hfig,u_plot_slice(idx_snap(uui)));
            end
        end
        
    end
    
    
end

linkaxes(n_ax,'x');

if ~isempty(main_figure)
    set(hfig,'WindowButtonDownFcn',{@copy_axes_callback,main_figure});
else
    set(hfig,'WindowButtonDownFcn',{@copy_axes_callback});
end


Map_info.Proj=obj.Proj;
Map_info.LonLim=LonLim;
Map_info.LatLim=LatLim;
setappdata(hfig,'Idx_select',[]);
setappdata(hfig,'Map_info',Map_info);
setappdata(hfig,'Map_input',obj);
end



function disp_line_name_callback(src,~,hfig,idx_obj)

ax=gca;
idx_selected=getappdata(hfig,'Idx_select');
obj=getappdata(hfig,'Map_input');

cp=ax.CurrentPoint;
x = cp(1,1);
y=cp(1,2);

switch hfig.SelectionType
    case 'normal'
        str=obj.get_str(idx_obj);
        idx_selected=idx_obj;
        u = findobj(ax,'Tag','name');
        delete(u);
        
        axes(ax);
        text(x,y,str{1},'Interpreter','None','Tag','name');
        
        %dim = [0.1 0.1 0.2 0.3];
        
        %annotation('textbox',dim,'String',str{1},'FitBoxToText','on','Interpreter','None','Tag','name');
        
        lines = findobj(ax,'Type','Line','Tag','Nav');
        for il=1:length(lines)
            if lines(il)==src
                set(lines(il),'color','r');
            else
                set(lines(il),'color','k');
            end
        end
        
    case 'alt'
        lines = findobj(ax,'Type','Line','Tag','Nav');
        idx_selected=unique([idx_selected idx_obj],'stable');
        for il=1:length(lines)
            if lines(il)==src
                set(lines(il),'color','r');
            end
        end
        
end
setappdata(hfig,'Idx_select',idx_selected);
end





