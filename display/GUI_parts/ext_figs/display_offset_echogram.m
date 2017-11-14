function display_offset_echogram(main_figure)


layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);


layers_Str=list_layers(layer,'nb_char',80);

[ping_new_mat,range_new_mat,data_new]=trans_obj.apply_line_depth(curr_disp.Fieldname);
if isempty(ping_new_mat)
    return;
end

h_fig=new_echo_figure(main_figure,...
    'Tag',sprintf('OffsetData %.0f%.0f',layer.ID_num,idx_freq),'Name',['Offset ' layers_Str{1}]);
ax=axes('Parent',h_fig,'Units','Normalized','position',[0 0 1 1],'xticklabel',{},'yticklabel',{},'nextplot','add','box','on');
%pax=pcolor(ax,ping_new_mat,range_new_mat,data_new);
pax=pcolor(ax,ping_new_mat,range_new_mat,data_new);
cax=curr_disp.getCaxField(curr_disp.Fieldname);
caxis(ax,cax);
[cmap,~,~,~,~,~]=init_cmap(curr_disp.Cmap);
colormap(ax,cmap);

axis(ax,'ij');
grid(ax,'on');
alpha_map=ones(size(range_new_mat));
alpha_map(data_new<cax(1))=0;
set(pax,'LineStyle','none');
% set(pax,'FaceAlpha','flat')
set(pax,'AlphaData',alpha_map,'facealpha','flat');
set(ax,'Xlim',[ping_new_mat(1) ping_new_mat(end)],'Ylim',[nanmin(range_new_mat(:)) nanmax(range_new_mat(:))]);
set(h_fig,'WindowButtonMotionFcn',@disp_depth);
end

function disp_depth(src,~)
cp=src.CurrentAxes.CurrentPoint;

delete(findobj(src,'Tag','depth_text'));
text(src.CurrentAxes,cp(1,1),cp(1,2),sprintf('Depth %.0fm\n Ping %.0f',cp(1,2),cp(1,1)),'tag','depth_text');

end