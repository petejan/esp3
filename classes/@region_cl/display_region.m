function h_fig=display_region(reg_obj,trans_obj)
output_reg=reg_obj.integrate_region(trans_obj);
idx_field=find_field_idx(trans_obj.Data,'sv');
cax=trans_obj.Data.SubData(idx_field).CaxisDisplay;
%     profile off;
%     profile viewer;
sv_disp=pow2db_perso(output_reg.Sv_mean_lin);


if isempty(find(~isnan(sv_disp(:)), 1))
    return;
end
%sv_disp(sv_disp<cax(1))=nan;

tt=sprintf('Region: %.0f',reg_obj.ID);
if size(sv_disp,1)>1&&size(sv_disp,2)>1
    
    x_disp=nanmean(output_reg.Ping_S);
    y_disp=nanmean(output_reg.y_node-output_reg.height/2,2);
    
    h_fig=figure('Name',tt,'NumberTitle','off','tag','regions');
    subplot(2,1,1)
    reg_plot=imagesc(x_disp(~isnan(x_disp)),y_disp(~isnan(y_disp)),sv_disp(~isnan(y_disp),~isnan(x_disp)));
    xlabel(sprintf('%s',reg_obj.Cell_w_unit))
    ylabel(sprintf('Depth (%s)',reg_obj.Cell_h_unit));

    caxis(cax);
    set(reg_plot,'alphadata',double(sv_disp(~isnan(y_disp),~isnan(x_disp))>cax(1)));
    colorbar;
    grid on;
    colormap jet;
    axis ij
    hold on;
    title(tt);
    subplot(2,1,2)
    plot(nanmean(output_reg.Sv_mean_lin_esp2,2),y_disp,'r');
    grid on;
    xlabel('Sv mean')
    ylabel(sprintf('Depth (%s)',reg_obj.Cell_h_unit));
    axis ij;
    grid on;
else
    h_fig=figure('Name',tt,'NumberTitle','off','tag','regions');
    plot(output_reg.Sv_mean_lin_esp2,output_reg.y_node-output_reg.height/2,'r');
    hold on
    plot(output_reg.Sv_mean_lin,output_reg.y_node-output_reg.height/2,'k');
    grid on;
    xlabel('Sv mean')
    ylabel(sprintf('Depth (%s)',reg_obj.Cell_h_unit));
    grid on;
    title(tt);
    axis ij;
end