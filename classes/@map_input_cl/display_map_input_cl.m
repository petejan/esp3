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
     hfig=new_echo_figure(main_figure,'Name','Navigation','Tag','nav');
end


%col_snap={'r','b','g','k','m'};
col_snap={'k'};


LongLim=[nan nan];
LatLim=[nan nan];


if ~strcmp(field,'Tag')
    [~,~,survey_name_num]=unique(obj.SurveyName);
    snap=unique([obj.Snapshot(:)';survey_name_num(:)']','rows');    
else
    [tag,~]=unique(obj.Regions.Tag);
    %tag={'EUP','GYP','MMU','DIA','ELC','LHE'};
    snap=ones(length(tag),2);
end


LongLim(1)=nanmin(LongLim(1),obj.LongLim(1));
LongLim(2)=nanmax(LongLim(2),obj.LongLim(2));
LatLim(1)=nanmin(LatLim(1),obj.LatLim(1));
LatLim(2)=nanmax(LatLim(2),obj.LatLim(2));

if p.Results.oneMap>0
    snap=[1 1];
end
nb_snap=size(snap,1);

nb_row=ceil(nb_snap/3);
nb_col=nanmin(nb_snap,3);

n_ax=gobjects(nb_snap,1);

for usnap=1:nb_snap
    n_ax(usnap)=subplot(nb_row,nb_col,usnap,'parent',hfig);
    hold(n_ax(usnap),'on');

    obj.Proj=init_proj('Mercator',LongLim,LatLim);
    if isempty(obj.Proj)
        close(hfig);
        return;
    end
   
    
    try
        m_grid('box','fancy','tickdir','in','parent',n_ax(usnap));
    catch
        fprintf(1,'Area to small to display Navigation\n');
        close(hfig);
        return;
    end
    
    
    if obj.Depth_Contour>0
        try
            [lat_c,lon_c,bathy]=get_etopo1(LatLim,LongLim);
            if length(lon_c)>=2&&length(lat_c)>=2
                [Cs,hs]=m_contour(lon_c,lat_c,bathy,-10000:obj.Depth_Contour:-1,'edgecolor',[.4 .4 .4],'visible','on','parent',n_ax(usnap));
                clabel(Cs,hs,'fontsize',8);
            end
        catch
            disp('Cannot find Etopo1 data...')
        end
    end
    
    try
        if obj.Coast>0
            m_gshhs_h('patch',[.5 .5 .5],'edgecolor','k','parent',n_ax(usnap));
        end
    catch
        disp('No Geographical data available...')
    end
end

if ~strcmp(field,'Tag')

    for usnap=1:nb_snap
        if p.Results.oneMap==0
            idx_snap=find(obj.Snapshot==snap(usnap,1)&survey_name_num(:)'==snap(usnap,2));
            
            if isempty(idx_snap)
                continue;
            end
            title(n_ax(usnap),sprintf('%s\n Snapshot %d',obj.Voyage{idx_snap(1)},snap(usnap,1)));
        else
            idx_snap=1:length(obj.Snapshot);
            title(n_ax(usnap),sprintf('%s\n',obj.Voyage{idx_snap(1)}));
        end
        
        for uui=1:length(idx_snap)
            if ~isempty(obj.Long{idx_snap(uui)})
                gobj=m_plot(n_ax(usnap),obj.Long{idx_snap(uui)},obj.Lat{idx_snap(uui)},'color','b','linewidth',2,'Tag','Nav');
                set(gobj,'ButtonDownFcn',{@disp_line_name_callback,hfig,idx_snap(uui)});
                m_plot(n_ax(usnap),obj.Long{idx_snap(uui)}(1),obj.Lat{idx_snap(uui)}(1),'Marker','o','Markersize',10,'Color',[0 0.5 0],'tag','start');
                if~isempty(main_figure)
                    create_context_menu_track(main_figure,hfig,gobj);
                end
                if ~isempty(obj.StationCode{idx_snap(uui)})
                    m_text(nanmean(obj.Long{idx_snap(uui)}),nanmean(obj.Lat{idx_snap(uui)}),obj.StationCode{idx_snap(uui)},'parent',n_ax(usnap),'color','r');
                end
            end
            
            
            
            if ~isempty(obj.SliceLong{idx_snap(uui)})
                if isempty(obj.Long{idx_snap(uui)})
                    m_plot(n_ax(usnap),obj.SliceLong{idx_snap(uui)}(1),obj.SliceLat{idx_snap(uui)}(1),'Marker','o','Markersize',10,'Color',[0 0.5 0],'tag','start');
                end
                gobj=m_plot(n_ax(usnap),obj.SliceLong{idx_snap(uui)},obj.SliceLat{idx_snap(uui)},'.k','Tag','Nav');
                set(gobj,'ButtonDownFcn',{@disp_line_name_callback,hfig,idx_snap(uui)});
                if~isempty(main_figure)
                    create_context_menu_track(main_figure,hfig,gobj);
                end
                if ~strcmp(field,'Tag')
                    switch lower(obj.PlotType)
                        case {'log10' 'db'}
                            ring_size=zeros(size(obj.(field){idx_snap(uui)}));
                            ring_size(obj.(field){idx_snap(uui)}>0)=obj.Rmax*(log10(1+obj.(field){idx_snap(uui)}(obj.(field){idx_snap(uui)}>0)/obj.ValMax));

                            
                        case {'sqrt' 'square root'}
                            ring_size=obj.Rmax*sqrt(obj.(field){idx_snap(uui)}/obj.ValMax);
                            
                        case 'linear'
                            ring_size=obj.Rmax*(obj.(field){idx_snap(uui)}/obj.ValMax);
                            
                    end
                    idx_rings=find(ring_size>0);
                    gobj=m_range_ring(obj.SliceLong{idx_snap(uui)}(idx_rings),obj.SliceLat{idx_snap(uui)}(idx_rings),ring_size(idx_rings),'color',col_snap{rem(usnap,length(col_snap))+1},'linewidth',1.5,'parent',n_ax(usnap),'Tag','Nav');
                    set(gobj,'ButtonDownFcn',{@disp_line_name_callback,hfig,idx_snap(uui)});
                    enterFcn =  @(figHandle, currentPoint)...
                        set(figHandle, 'Pointer', 'hand');
                    iptSetPointerBehavior(gobj,enterFcn);
                    if~isempty(main_figure)
                        create_context_menu_track(main_figure,hfig,gobj);
                    end
                    

                end
            end
        end
        
        
    end
    
    
else
    
    for utag=1:length(tag)
        title(n_ax(utag),sprintf('%s: %s\n',obj.Voyage{1},tag{utag}));
        if strcmp(field,'Tag')
            ireg_tag=find(strcmp(obj.Regions.Tag,tag{utag}));
            if isempty(ireg_tag)
                continue;
            end
            [~,~,strat_vec_num]=unique([obj.Regions.Stratum{ireg_tag}]);
            mat_surv_data=[obj.Regions.Snapshot(ireg_tag);strat_vec_num';obj.Regions.Transect(ireg_tag)]';
            [~,unique_trans,trans_ids]=unique(mat_surv_data,'rows');
            for itrans=1:length(unique_trans)
                itrans_curr=find(trans_ids==itrans);
                m_text(nanmean(obj.Regions.Long_m(ireg_tag(itrans_curr))),nanmean(obj.Regions.Lat_m(ireg_tag(itrans_curr))),tag{utag},'parent',n_ax(utag),'color','r');
                m_text(nanmean(obj.Regions.Long_m(ireg_tag(itrans_curr))),nanmean(obj.Regions.Lat_m(ireg_tag(itrans_curr))),sprintf('\n,%.0f',obj.Regions.Transect(ireg_tag(itrans_curr(1)))),'parent',n_ax(utag),'color','b');
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
Map_info.LongLim=LongLim;
Map_info.LatLim=LatLim;
setappdata(hfig,'Idx_select',[]);
set(n_ax,'UserData',Map_info);
setappdata(hfig,'Map_input',obj);
end



function disp_line_name_callback(src,~,hfig,idx_obj)

ax=get(src,'parent');
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
        
        text(x,y,str{1},'Interpreter','None','Tag','name','parent',ax);
        
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





