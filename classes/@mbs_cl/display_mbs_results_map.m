function display_mbs_results_map(mbs,ax)

mbs_head=mbs.Header;
%mbs_in=mbs.Input;
mbs_out=mbs.Output;

sliced_abscf=mbs_out.slicedTransectSum.Data;

nb_transect=size(sliced_abscf,1);

snapshot=zeros(1,nb_transect);
lat=cell(1,nb_transect);
lon=cell(1,nb_transect);
abscf=cell(1,nb_transect);
str=cell(1,nb_transect);
str_disp=cell(1,nb_transect);
lat_lim=[nan nan];
lon_lim=[nan nan];



for i=1:nb_transect
    lat{i}=sliced_abscf{i,6};
    lon{i}=sliced_abscf{i,7};
    lon{i}(lon{i}<0)=lon{i}(lon{i}<0)+360;
    abscf{i}=sliced_abscf{i,8};
    snapshot(i)=sliced_abscf{i,1};
    
    if ischar(sliced_abscf{i,2})
        str{i}=sprintf('Snapshot %d\n Stratum %s\n Transect %d\n',...
            sliced_abscf{i,1},sliced_abscf{i,2},sliced_abscf{i,3});
        str_disp{i}=sprintf('St %s T %d',...
            sliced_abscf{i,2},sliced_abscf{i,3});
    else
        str{i}=sprintf('Snapshot %d\n Stratum %d\n Transect %d\n',...
            sliced_abscf{i,1},sliced_abscf{i,2},sliced_abscf{i,3});
        str_disp{i}=sprintf('St %d T %d',...
            sliced_abscf{i,2},sliced_abscf{i,3});
    end
    
    lat_lim(1)=nanmin(lat_lim(1),nanmin(lat{i}));
    lon_lim(1)=nanmin(lon_lim(1),nanmin(lon{i}));
    lat_lim(2)=nanmax(lat_lim(2),nanmax(lat{i}));
    lon_lim(2)=nanmax(lon_lim(2),nanmax(lon{i}));
end


abscf_max=1e-3;


axes(ax);hold on;
m_proj('lambert','long',[lon_lim(1)-0.01 lon_lim(2)+0.01],'lat',[lat_lim(1)-0.01 lat_lim(2)+0.01]);
title(sprintf('%s',mbs_head.title));
m_grid('box','fancy','tickdir','in');
for uui=1:length(snapshot)
    if ~isempty(lon{uui})
        u_plot(uui)=m_plot(lon{uui},lat{uui},'k');
        set(u_plot(uui),'ButtonDownFcn',{@disp_line_name_callback,str{uui}});
        ring_size=sqrt(abscf{uui}/abscf_max);
        %m_plot(output_esp2(idx_snap(uui)).slice_lon,output_esp2(idx_snap(uui)).slice_lat,'.k','markersize',2);
        idx_rings=find(ring_size>0);
        for uuj=idx_rings
            m_range_ring(lon{uui}(uuj),lat{uui}(uuj),ring_size(uuj),'color','r');
        end
    end
end
try
    m_gshhs_h('patch',[.5 .5 .5],'edgecolor','k');
catch
    disp('No Geographical data available...')
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
