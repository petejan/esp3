function h_fig=display_region(reg_obj,trans_obj,varargin)

p = inputParser;


addRequired(p,'reg_obj',@(obj) isa(obj,'region_cl'));
addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl')|isstruct(obj));

addParameter(p,'Cax',init_cax('sv'),@isnumeric);
addParameter(p,'Cmap','jet',@ischar);

parse(p,reg_obj,trans_obj,varargin{:});



if isa(trans_obj,'transceiver_cl')
    output_reg=trans_obj.integrate_region(reg_obj);
else
    output_reg=trans_obj;
end

if isempty(output_reg)
    h_fig=[];
    return;
end

cax=p.Results.Cax;

sv_disp=pow2db_perso(output_reg.Sv_mean_lin);


if ~any(~isnan(sv_disp))
    h_fig=[];
    return;
end


tt=sprintf('Region: %.0f',reg_obj.ID);

switch reg_obj.Cell_w_unit
    case 'pings'
        x_disp=nanmean(output_reg.Ping_S,1);
    case 'meters'
        x_disp=(nanmean(output_reg.Dist_S,1)+nanmean(output_reg.Dist_E,1))/2;
end

switch(reg_obj.Reference)
    case 'Surface'
        y_disp=nanmean(output_reg.y_node+output_reg.height/2,2);
    case 'Bottom'
        y_disp=-nanmean(output_reg.y_node+output_reg.height/2,2);
end
mat_size=size(sv_disp);
h_fig=new_echo_figure([],'Name',tt,'Tag','regions','Units','Normalized','Position',[0.1 0.2 0.8 0.6]);
ax_in=axes('Parent',h_fig,'Units','Normalized','position',[0.2 0.25 0.7 0.65],'xticklabel',{},'yticklabel',{},'nextplot','add','box','on');
title(ax_in,tt);
if  ~any(mat_size==1)
    reg_plot=pcolor(ax_in,repmat(x_disp,length(y_disp),1),repmat(y_disp,1,length(x_disp)),sv_disp);
    set(reg_plot,'alphadata',double(sv_disp>cax(1)),'facealpha','flat','edgecolor','none');
end
%shading(ax_in,'interp')
ax_in.XTick=(x_disp(1):reg_obj.Cell_w:x_disp(end));
ax_in.YTick=sort((y_disp(1):reg_obj.Cell_h:y_disp(end)));
caxis(cax);

colorbar(ax_in,'Position',[0.92 0.25 0.03 0.65]);
grid on;
[cmap,~,~,col_grid,~]=init_cmap(p.Results.Cmap);
colormap(ax_in,cmap);
set(ax_in,'GridColor',col_grid);

if strcmp(reg_obj.Reference,'Surface')
    axis ij
end



ax_horz=axes('Parent',h_fig,'Units','Normalized','position',[0.2 0.1 0.7 0.15],'nextplot','add','box','on');
plot(x_disp,pow2db_perso(nanmean(output_reg.Sv_mean_lin_esp2,1)),'r');
grid on;
xlabel(sprintf('%s',reg_obj.Cell_w_unit))
ylabel('Sv mean(dB)')
ax_horz.XTick=(x_disp(1):reg_obj.Cell_w:x_disp(end));
ax_horz.XTickLabelRotation=90;

switch reg_obj.Cell_w_unit
    case 'meters'
        ax_horz.XAxis.TickLabelFormat='%.0fm';
    case 'pings'
        ax_horz.XAxis.TickLabelFormat='%.0f';
end

ax_vert=axes('Parent',h_fig,'Units','Normalized','position',[0.05 0.25 0.15 0.65],'xaxislocation','top','nextplot','add','box','on');
plot(pow2db_perso(nanmean(output_reg.Sv_mean_lin_esp2,2)),y_disp,'r');
xlabel('Sv mean (db)')

if strcmp(reg_obj.Reference,'Surface')
    axis ij;
    ylabel(sprintf('Depth (%s)',reg_obj.Cell_h_unit));
else
    ylabel(sprintf('Above bottom(%s)',reg_obj.Cell_h_unit));
end

grid on;
ax_vert.YTick=(y_disp(1):reg_obj.Cell_h:y_disp(end))+reg_obj.Cell_h/2;

ax_vert.YAxis.TickLabelFormat='%.0gm';
linkaxes([ax_in ax_vert],'y');
linkaxes([ax_in ax_horz],'x');
set(ax_in,'Xlim',[x_disp(1)-reg_obj.Cell_w/2 x_disp(end)+reg_obj.Cell_w/2]);
set(ax_in,'Ylim',[y_disp(1)-reg_obj.Cell_h/2 y_disp(end)+reg_obj.Cell_h/2]);
