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
    
    if isempty(find(~isnan(sv_disp(:)), 1))
        return;
    end
    %sv_disp(sv_disp<cax(1))=nan;

    filedisp=layer.Filename{1};

    tt=sprintf('File: %s Region: %.0f',filedisp,active_reg.ID);
    if size(sv_disp,1)>1&&size(sv_disp,2)>1
        
        x_disp=nanmean(active_reg.Output.Ping_S);
        y_disp=nanmean(active_reg.Output.y_node-active_reg.Output.height/2,2);
        
        new_fig=figure('Name',tt,'NumberTitle','off','tag','regions');
        subplot(2,1,1)
        reg_plot=imagesc(x_disp(~isnan(x_disp)),y_disp(~isnan(y_disp)),sv_disp(~isnan(y_disp),~isnan(x_disp)));
        xlabel(sprintf('%s',active_reg.Cell_w_unit))
        ylabel(sprintf('Depth (%s)',active_reg.Cell_h_unit));
        %shading interp
        caxis(cax);
        set(reg_plot,'alphadata',double(sv_disp(~isnan(y_disp),~isnan(x_disp))>cax(1)));
        colorbar;
        grid on;
        colormap jet;
        axis ij
        hold on;
        title(tt);
        subplot(2,1,2)
        plot(nanmean(active_reg.Output.Sv_mean_lin_esp2,2),y_disp,'r');
        grid on;
        xlabel('Sv mean')
        ylabel(sprintf('Depth (%s)',active_reg.Cell_h_unit));
        axis ij;
        grid on;
    else
      new_fig=figure('Name',tt,'NumberTitle','off','tag','regions');
        plot(active_reg.Output.Sv_mean_lin_esp2,active_reg.Output.y_node-active_reg.Output.height/2,'r');
        hold on
        plot(active_reg.Output.Sv_mean_lin,active_reg.Output.y_node-active_reg.Output.height/2,'k');
        grid on;
        xlabel('Sv mean')
        ylabel(sprintf('Depth (%s)',active_reg.Cell_h_unit));
        grid on;
        title(tt);
        axis ij;
    end
else
    return;
end


hfigs=[hfigs new_fig];
setappdata(main_figure,'ExternalFigures',hfigs);


end