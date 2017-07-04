function init_st_ax(main_figure,ax)


layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
trans_obj=layer.get_trans(curr_disp.Freq);

if isempty(trans_obj)
    return;
end
cax=curr_disp.getCaxField('sp');
cmap_name=curr_disp.Cmap;

[cmap,~,~,~,~,~]=init_cmap(cmap_name);
caxis(ax,cax);
colormap(ax,cmap);

x0=trans_obj.Config.AngleOffsetAthwartship;
y0=trans_obj.Config.AngleOffsetAlongship;

[x1,y1]=get_ellipse_xy(trans_obj.Config.BeamWidthAthwartship,trans_obj.Config.BeamWidthAlongship,...
    x0,y0,100);
[x2,y2]=get_ellipse_xy(trans_obj.Config.BeamWidthAthwartship/2,trans_obj.Config.BeamWidthAlongship/2,...
    x0,y0,100);
axis(ax,'equal');hold(ax,'on');ax.Visible='off';
plot(ax,[x0-trans_obj.Config.BeamWidthAthwartship x0+trans_obj.Config.BeamWidthAthwartship],[y0 y0],'k');
plot(ax,[x0 x0],[y0-trans_obj.Config.BeamWidthAlongship y0+trans_obj.Config.BeamWidthAlongship],'k');
plot(ax,x2,y2,'--k');plot(ax,x1,y1,'k');
text(ax,x0+trans_obj.Config.BeamWidthAthwartship,y0,sprintf('%.1f^\\circ',x0+trans_obj.Config.BeamWidthAthwartship));
text(ax,x0-trans_obj.Config.BeamWidthAthwartship,y0,sprintf('%.1f^\\circ',x0-trans_obj.Config.BeamWidthAthwartship));
text(ax,x0,y0+trans_obj.Config.BeamWidthAlongship,sprintf('%.1f^\\circ',y0+trans_obj.Config.BeamWidthAlongship));
text(ax,x0,y0-trans_obj.Config.BeamWidthAlongship,sprintf('%.1f^\\circ',y0-trans_obj.Config.BeamWidthAlongship));
