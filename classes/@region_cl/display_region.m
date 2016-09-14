function h_fig=display_region(reg_obj,trans_obj)
output_reg=reg_obj.integrate_region(trans_obj);

[cax,~]=init_cax('sv');

sv_disp=pow2db_perso(output_reg.Sv_mean_lin);


if ~any(~isnan(sv_disp))
    h_fig=[];
    return;
end


tt=sprintf('Region: %.0f',reg_obj.ID);

x_disp=nanmean(output_reg.Ping_S);
switch(reg_obj.Reference)
    case 'Surface'
        y_disp=nanmean(output_reg.y_node+output_reg.height/2,2);
    case 'Bottom'
        y_disp=-nanmean(output_reg.y_node+output_reg.height/2,2);
end

h_fig=figure('Name',tt,'NumberTitle','off','tag','regions','Units','Normalized','Position',[0.1 0.2 0.8 0.6]);
ax_in=axes('Parent',h_fig,'Units','Normalized','position',[0.2 0.25 0.7 0.65],'xticklabel',{},'yticklabel',{},'nextplot','add','box','on');
reg_plot=imagesc(x_disp(~isnan(x_disp)),y_disp(~isnan(y_disp)),sv_disp(~isnan(y_disp),~isnan(x_disp)));
ax_in.XTick=(x_disp(1):reg_obj.Cell_w:x_disp(end))-reg_obj.Cell_w/2;
ax_in.YTick=sort((y_disp(1):reg_obj.Cell_h:y_disp(end))-reg_obj.Cell_h/2);

caxis(cax);
set(reg_plot,'alphadata',double(sv_disp(~isnan(y_disp),~isnan(x_disp))>cax(1)));
colorbar(ax_in,'Position',[0.92 0.25 0.03 0.65]);
grid on;
colormap jet;
if strcmp(reg_obj.Reference,'Surface')
    axis ij
end
title(tt);

ax_horz=axes('Parent',h_fig,'Units','Normalized','position',[0.2 0.1 0.7 0.15],'nextplot','add','box','on');
plot(x_disp,pow2db_perso(nanmean(output_reg.Sv_mean_lin_esp2)),'r');
grid on;
xlabel(sprintf('%s',reg_obj.Cell_w_unit))
ylabel('Sv mean(dB)')
ax_horz.XTick=(x_disp(1):reg_obj.Cell_w:x_disp(end))+reg_obj.Cell_w/2;
ax_horz.XTickLabelRotation=90;

ax_vert=axes('Parent',h_fig,'Units','Normalized','position',[0.05 0.25 0.15 0.65],'xaxislocation','top','nextplot','add','box','on');
plot(nanmean(output_reg.Sv_mean_lin_esp2,2),y_disp,'r');
xlabel('Sv mean (lin)')

if strcmp(reg_obj.Reference,'Surface')
    axis ij;
    ylabel(sprintf('Depth (%s)',reg_obj.Cell_h_unit));
else
   ylabel(sprintf('Above bottom(%s)',reg_obj.Cell_h_unit)); 
end
grid on;
ax_vert.YTick=(y_disp(1):reg_obj.Cell_h:y_disp(end))+reg_obj.Cell_h/2;
ax_vert.YAxis.TickLabelFormat='%.2g';


linkaxes([ax_in ax_vert],'y');
linkaxes([ax_in ax_horz],'x');
set(ax_in,'Xlim',[x_disp(1)-reg_obj.Cell_w/2 x_disp(end)+reg_obj.Cell_w/2]);
set(ax_in,'Ylim',[y_disp(1)-reg_obj.Cell_h/2 y_disp(end)+reg_obj.Cell_h/2]);
