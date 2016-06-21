function format_main_axes(ax,cax,ax_type,xdata_grid,ydata_grid,xdata,ydata,dx,dy)
if ~isempty(cax)
    axes(ax);
    if cax(2)<=cax(1)
        cax(2)=cax(1)+10*abs(cax(1))/100;
    end
    caxis(cax);
end
if length(xdata)>1
    set(ax,'xlim',[xdata(1) xdata(end)]);
end
if length(ydata)>1
    set(ax,'ylim',[ydata(1) ydata(end)]);
end
zoom reset;


idx_xticks=(diff(rem(xdata_grid,dx))<0);
idx_yticks=(diff(rem(ydata_grid,dy))<0);

grid on;
axis ij;
set(ax,'Xtick',xdata(idx_xticks),'Ytick',ydata(idx_yticks),'XAxisLocation','top');
xlabel_out=format_label(xdata_grid(idx_xticks),ax_type);
ylabel_out=format_label(ydata_grid(idx_yticks),'distance');
set(ax,'XtickLabel',xlabel_out,'YtickLabel',ylabel_out,'XTickLabelRotation',90,'box','on','visible','on');


end