function display_region_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
region_tab_comp=getappdata(main_figure,'Region_tab');
hfigs=getappdata(main_figure,'ExternalFigures');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
Transceiver=layer.Transceivers(idx_freq);
list_reg = list_regions(layer.Transceivers(idx_freq));
idx_field=find_field_idx(layer.Transceivers(idx_freq).Data,'sv');
cax=layer.Transceivers(idx_freq).Data.SubData(idx_field).CaxisDisplay;


if ~isempty(list_reg)
    active_reg=Transceiver.Regions(get(region_tab_comp.tog_reg,'value'));
    sv_disp=active_reg.Output.Sv_mean;
    %sv_disp(sv_disp<cax(1))=nan;
    tt=sprintf('File: %s Region: %.0f',layer.Filename,active_reg.ID);
    if size(sv_disp,1)>1&&size(sv_disp,2)>1
        new_fig=figure('Name',tt,'NumberTitle','off','tag','regions');
        subplot(2,1,1)
        pcolor(active_reg.Output.x_node,active_reg.Output.y_node,sv_disp)
        xlabel(sprintf('%s',active_reg.Cell_w_unit))
        ylabel(sprintf('Depth (%s)',active_reg.Cell_h_unit));
        shading interp
        caxis(cax);
        colorbar;
        grid on;
        colormap jet;
        axis ij
        hold on;
        title(tt);
        subplot(2,1,2)
        plot(nanmean(active_reg.Output.Sv_mean_esp2,2),nanmean(active_reg.Output.y_node,2),'r');
        grid on;
        xlabel('Sv mean')
        ylabel(sprintf('Depth (%s)',active_reg.Cell_h_unit));
        axis ij;
        grid on;
    else
      new_fig=figure('Name',tt,'NumberTitle','off','tag','regions');
        plot(active_reg.Output.y_node,active_reg.Output.Sv_mean_lin_esp2,'r');
        grid on;
        ylabel('Sv mean')
        xlabel(sprintf('Depth (%s)',active_reg.Cell_h_unit));
        grid on;
        title(tt);
    end
else
    return;
end


hfigs=[hfigs new_fig];
setappdata(main_figure,'ExternalFigures',hfigs);


end