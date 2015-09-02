function update_ytick_labels(~,~,ax)

%axc=get(ax,'children');

%delete(axc(strcmp(get(axc,'tag'),'ytick')));

ytick=get(ax,'ytick');

yticklabel=format_label(ytick,'Distance');

set(ax,'YTickLabel',yticklabel);
% 
% ylim=get(ax,'ylim');
% yticknorm=1-(ytick-ylim(1))/(ylim(2)-ylim(1));
% idx_y=(yticknorm<=1&yticknorm>=0);
% 
% if ~isempty(idx_y)
%     xpos=0.01;
%         text(repmat(xpos,1,nansum(idx_y)),yticknorm(idx_y),yticklabel(idx_y),...
%         'units','normalized',...
%         'horizontalalignment','left','verticalalignment','middle','fontsize',get(ax,'fontsize'),'parent',ax,'tag','ytick');
% %     tic
% %     i_idx=find(idx_y);
% %     for i=i_idx;
% %      text(xpos,yticknorm(i),yticklabel(i),...
% %         'units','normalized',...
% %         'horizontalalignment','left','verticalalignment','middle','fontsize',get(ax,'fontsize'),'parent',ax,'tag','ytick');
% %     end
% %     toc
% end

end