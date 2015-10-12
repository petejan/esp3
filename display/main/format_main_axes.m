function format_main_axes(ax,cax,xdata,ydata,idx_xlim,idx_ylim,dx,dy,new)
if ~isempty(cax)
    axes(ax);
    if cax(2)<=cax(1)
        cax(2)=cax(1)+10*abs(cax(1))/100;
    end
    caxis(cax);
end

set(ax,'xlim',[xdata(1) xdata(end)]);
set(ax,'ylim',[ydata(1) ydata(end)]);
zoom reset;

if new==0 && idx_xlim(1)<idx_xlim(2) && idx_ylim(1)<idx_ylim(2)
    set(ax,'xlim',xdata(idx_xlim));
    set(ax,'ylim',ydata(idx_ylim));
end
grid on;
axis ij;
set(ax,'Xtick',(xdata(1):dx:xdata(end)),'ytick',(ydata(1):dy:ydata(end)),'XTickLabelRotation',90,'box','on');

end