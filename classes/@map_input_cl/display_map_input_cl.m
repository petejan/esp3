function display_map_input_cl(obj_tot,hfig,main_figure,field)
snap=[];
%col_snap={'r','b','g','k','m'};
col_snap={'k'};

if nargin<4
    field='SliceAbscf';
end

set(hfig,'Name','Navigation','NumberTitle','off','tag','nav');

LonLim=[nan nan];
LatLim=[nan nan];

for uuobj=1:length(obj_tot)
    obj=obj_tot(uuobj);
    snap=union(snap,unique(obj.Snapshot));
    LonLim(1)=nanmin(LonLim(1),obj.LonLim(1));
    LonLim(2)=nanmax(LonLim(2),obj.LonLim(2));
    LatLim(1)=nanmin(LatLim(1),obj.LatLim(1));
    LatLim(2)=nanmax(LatLim(2),obj.LatLim(2));
end

nb_row=ceil(length(snap)/3);
nb_col=nanmin(length(snap),3);
% ax_pos=get(ax,'position');
%
% dcol=ax_pos(3)/nb_col;
% drow=ax_pos(4)/nb_row;

% fig=get(ax,'parent');
% delete(ax);
n_ax=gobjects(length(snap),1);
figure(hfig);

for usnap=1:length(snap)
    %     n_ax(usnap)=axes('parent',fig);
    %     idx_r=ceil(usnap/nb_col);
    %     idx_c=usnap-nb_col*(idx_r-1);
    %     set(n_ax(usnap),'position',[ax_pos(1)+dcol*(idx_c-1) ax_pos(2)+drow*(idx_r-1) dcol drow]);
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
                return
            end
        end
    end
    
    axes(n_ax(usnap));
    hold on;
   
    
%     context_menu=uicontextmenu;
%     n_ax(usnap).UIContextMenu=context_menu;
%     uimenu(context_menu,'Label','Copy Axes to new Figure','Callback',{@copy_axes_callback});
%     
    try
        m_grid('box','fancy','tickdir','in');
    catch
       fprintf(1,'Area to small to display Navigation\n');
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

for uuobj=1:length(obj_tot)

    obj=obj_tot(uuobj);
    str=cell(1,length(obj.Transect));
    str_disp=cell(1,length(obj.Transect));
    for i=1:length(obj.Transect)
        if ~isempty(obj.Stratum{i})
            if ischar(obj.Stratum{i})
                str{i}=sprintf('File %s\n Stratum %s\n Transect %d\n',...
                    obj.Filename{i},obj.Stratum{i},obj.Transect(i));
                str_disp{i}=sprintf('St %s T %d',...
                    obj.Stratum{i},obj.Transect(i));
            else
                str{i}=sprintf('File %s\n Stratum %d\n Transect %d\n',...
                    obj.Filename{i},obj.Stratum{i},obj.Transect(i));
                str_disp{i}=sprintf('St %d T %d',...
                    obj.Stratum{i},obj.Transect(i));
            end
        else
            str_disp{i}='';
            str{i}=obj.Filename{i};
        end
        
    end
    
    for usnap=1:length(snap)
        idx_snap=find(obj.Snapshot==snap(usnap));
        
        if isempty(idx_snap)
           continue;
        end
        axes(n_ax(usnap));
        hold on;
        title(sprintf('%s\n Snapshot %d',obj.Trip{idx_snap(1)},snap(usnap)));

        for uui=1:length(idx_snap)
            if ~isempty(obj.Lon{idx_snap(uui)})
                u_plot(idx_snap(uui))=m_plot(obj.Lon{idx_snap(uui)},obj.Lat{idx_snap(uui)},'color','r','linewidth',2);
                set(u_plot(idx_snap(uui)),'ButtonDownFcn',{@disp_line_name_callback,str{idx_snap(uui)}});
                if obj.Transect(idx_snap(uui))>0
                    m_text(obj.Lon{idx_snap(uui)}(1),obj.Lat{idx_snap(uui)}(1),num2str(obj.Transect(idx_snap(uui)),'%.0f'),'Fontsize',16,'Fontweight','Bold','Color','r');
                end
            end
            
            if ~isempty(obj.SliceLon{idx_snap(uui)})
                if isempty(obj.Lon{idx_snap(uui)})
                    m_text(obj.SliceLon{idx_snap(uui)}(1),obj.SliceLat{idx_snap(uui)}(1),num2str(obj.Transect(idx_snap(uui)),'%.0f'),'Fontsize',16,'Fontweight','Bold','Color','r');
                end
                u_plot_slice(idx_snap(uui))=m_plot(obj.SliceLon{idx_snap(uui)},obj.SliceLat{idx_snap(uui)},'xk');
                set(u_plot_slice(idx_snap(uui)),'ButtonDownFcn',{@disp_line_name_callback,str{idx_snap(uui)}});
                ring_size=obj.Rmax*sqrt(obj.(field){idx_snap(uui)}/obj.ValMax);
                idx_rings=find(ring_size>0);
                for uuj=idx_rings
                    m_range_ring(obj.SliceLon{idx_snap(uui)}(uuj),obj.SliceLat{idx_snap(uui)}(uuj),ring_size(uuj),'color',col_snap{rem(usnap,length(col_snap))+1},'linewidth',1.5);
                end
            end
        end
        
    end
end

if nargin>2
    set(hfig,'WindowButtonDownFcn',{@copy_axes_callback,main_figure});
else
    set(hfig,'WindowButtonDownFcn',{@copy_axes_callback});
end


Map_info.Proj=obj.Proj;
Map_info.LonLim=LonLim;
Map_info.LatLim=LatLim;
setappdata(hfig,'Map_info',Map_info);
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