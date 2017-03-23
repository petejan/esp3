function display_offset_echogram(main_figure)


layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find(layer.Frequencies==curr_disp.Freq);
if isempty(layer)
    return;
end

layers_Str=list_layers(layer,'nb_char',80);

[ping_new_mat,range_new_mat,data_new]=layer.Transceivers(idx_freq).apply_line_depth(curr_disp.Fieldname);

h_fig=new_echo_figure(main_figure,...
    'Tag',sprintf('OffsetData %.0f%.0f',layer.ID_num,idx_freq),'Name',['Offset ' layers_Str{1}]);
ax=axes('Parent',h_fig,'Units','Normalized','position',[0 0 1 1],'xticklabel',{},'yticklabel',{},'nextplot','add','box','on');
%pax=pcolor(ax,ping_new_mat,range_new_mat,data_new);
pax=imagesc(ax,ping_new_mat(1,:),range_new_mat(:,1),data_new);
cax=curr_disp.getCaxField(curr_disp.Fieldname);
caxis(ax,cax);
[cmap,~,~,~,~,~]=init_cmap(curr_disp.Cmap);
colormap(ax,cmap);

axis(ax,'ij');
grid(ax,'on');
alpha_map=ones(size(range_new_mat));
alpha_map(data_new<cax(1))=0;
% shading(ax,'flat');
% set(pax,'FaceAlpha','flat')
set(pax,'AlphaData',alpha_map);
set(ax,'Xlim',[ping_new_mat(1) ping_new_mat(end)],'Ylim',[range_new_mat(1) range_new_mat(end)]);
set(h_fig,'WindowButtonMotionFcn',@disp_depth);
end

function disp_depth(src,~)
cp=src.CurrentAxes.CurrentPoint;

delete(findobj(src,'Tag','depth_text'));
text(src.CurrentAxes,cp(1,1),cp(1,2),sprintf('Depth %.0fm\n Ping %.0f',cp(1,2),cp(1,1)),'tag','depth_text');

end