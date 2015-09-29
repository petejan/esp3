
function hfig=disp_curves(layer,tag)

idx=layer.get_curves_per_tag(tag);
X_cumul=[];
Y_cumul=[];
if~isempty(idx);
    
    hfig=figure('Name','Curves','NumberTitle','off','tag','curves');
    hold on;
    grid on;
    
    for j=1:length(idx)
        curve_curr=layer.Curves(idx(j));
        plot(curve_curr.XData,curve_curr.YData,'linewidth',0.2);
        X_cumul=[X_cumul;curve_curr.XData];
        Y_cumul=[Y_cumul;curve_curr.YData];
    end
    
    if ~isempty(strfind(curve_curr.Yunit,'dB'))
        y_mean=10*log10(nanmean(10.^(Y_cumul/10)));
        
    else
        y_mean=nanmean(Y_cumul/10);
    end
    y_std=nanstd(Y_cumul);
    plot(curve_curr.XData,y_mean,'k','linewidth',2);
%              plot(curve_curr.XData,y_mean+y_std,'--k');
%              plot(curve_curr.XData,y_mean-y_std,'--k');
    xlabel(curve_curr.Xunit);
    ylabel(curve_curr.Yunit);
    title(curve_curr.Tag);
end

end