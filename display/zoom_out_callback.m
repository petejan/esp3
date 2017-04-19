%% zoom_out_callback.m
%
% TODO
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
% * |src|: TODO
% * |main_figure|: TODO
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: complete header and in-code commenting
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments (Alex Schimel)
% * 2017-03-21: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function zoom_out_callback(src,~,main_figure)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);


xdata_tot=trans.get_transceiver_pings();       
ydata_tot=trans.get_transceiver_samples();

ah=axes_panel_comp.main_axes;
switch src.SelectionType  
    case 'normal'

        x_lim_ori=get(ah,'XLim');
        y_lim=get(ah,'YLim');
        
        dx=abs(diff(x_lim_ori));
        dy=diff(y_lim);
        
        x_lim(1)=x_lim_ori(1)-dx/2;
        y_lim(1)=y_lim(1)-dy/2;
        x_lim(2)=x_lim_ori(2)+dx/2;
        y_lim(2)=y_lim(2)+dy/2;
        
        x_lim(x_lim>nanmax(xdata_tot))=nanmax(xdata_tot);
        x_lim(x_lim<nanmin(xdata_tot))=nanmin(xdata_tot);
        
%         if diff(x_lim)>screensize(3)
%            x_lim=[nanmean(x_lim_ori)-screensize(3)/2 nanmean(x_lim_ori)+screensize(3)/2];
%         end
        
        y_lim(y_lim>nanmax(ydata_tot))=nanmax(ydata_tot);
        y_lim(y_lim<nanmin(ydata_tot))=nanmin(ydata_tot);
    case {'alt','open'}
        %x_lim=[nanmin(xdata_tot) nanmin(xdata_tot)+screensize(3)];
        x_lim=[nanmin(xdata_tot) nanmax(xdata_tot)];
        y_lim=[nanmin(ydata_tot) nanmax(ydata_tot)];
    otherwise
        return;
        
end
set(ah,'XLim',x_lim,'YLim',y_lim);

end
