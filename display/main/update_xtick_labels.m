function update_xtick_labels(~,~,ax,ax_type)

%axc=get(ax,'children');

%delete(axc(strcmp(get(axc,'tag'),'xtick')));

xtick=get(ax,'xtick');

xticklabel=format_label(xtick,ax_type);

set(ax,'XTickLabel',xticklabel);
set(ax,'XTickLabelRotation',-90);
% 
% xlim=get(ax,'xlim');
% xticknorm=(xtick-xlim(1))/(xlim(2)-xlim(1));
% 
% idx_x=(xticknorm<=1&xticknorm>=0);
% 
% if ~isempty(idx_x)
%     ypos=0.05;
%     text(xticknorm(idx_x),repmat(ypos,1,nansum(idx_x)),xticklabel(idx_x),...
%         'units','normalized',...
%         'horizontalalignment','center','verticalalignment','middle','fontsize',get(ax,'fontsize'),'parent',ax,'tag','xtick','rotation',90);
% end


end
