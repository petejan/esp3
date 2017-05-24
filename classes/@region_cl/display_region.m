%% display_region.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |reg_obj|: TODO: write description and info on variable
% * |trans_obj|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |h_fig|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function h_fig = display_region(reg_obj,trans_obj,varargin)

p = inputParser;



addRequired(p,'reg_obj',@(obj) isa(obj,'region_cl'));
addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl')|isstruct(obj));
addParameter(p,'line_obj',[],@(x) isa(x,'line_cl')||isempty(x));
addParameter(p,'Name',reg_obj.print(),@ischar);
addParameter(p,'Cax',init_cax('sv'),@isnumeric);
addParameter(p,'Cmap','jet',@ischar);
addParameter(p,'alphadata',[],@isnumeric);
addParameter(p,'main_figure',[],@(h) isempty(h)|isa(h,'matlab.ui.Figure'));

parse(p,reg_obj,trans_obj,varargin{:});

if isa(trans_obj,'transceiver_cl')
%       profile on;
%      output_reg_old=trans_obj.integrate_region(reg_obj);
        output_reg=trans_obj.integrate_region_v2(reg_obj,'line_obj',p.Results.line_obj);
%     compare_reg_output(output_reg_old,output_reg,reg_obj.Reference);
%      profile off;
%     profile viewer;
else
    output_reg=trans_obj;
end

if isempty(output_reg)
    h_fig=[];
    return;
end

if~isempty(p.Results.main_figure)
    curr_disp=getappdata(p.Results.main_figure,'Curr_disp');
else
    curr_disp=[];
end

if ~isempty(curr_disp)
    if ismember('Cax',p.UsingDefaults)
        cax=curr_disp.getCaxField('sv');
        cax_list=addlistener(curr_disp,'Cax','PostSet',@(src,envdata)listenCaxReg(src,envdata));
        
    else
        cax=p.Results.Cax;
        cax_list=[];
    end
    
    if ismember('Cmap',p.UsingDefaults)
        cmap_name=curr_disp.Cmap;
        cmap_list=addlistener(curr_disp,'Cmap','PostSet',@(src,envdata)listenCmapReg(src,envdata));
    else
        cmap_name=p.Results.Cmap;
        cmap_list=[];
    end
    
else
    cax=p.Results.Cax;
    cmap_name=p.Results.Cmap;
    cmap_list=[];
    cax_list=[];
end




sv_disp=pow2db_perso(output_reg.Sv_mean_lin);

if ~ismember('alphadata',p.UsingDefaults)&&all(size(sv_disp)==size(p.Results.alphadata))
    alphadata=p.Results.alphadata;
else
   alphadata=double(sv_disp>cax(1)); 
end


if ~any(~isnan(sv_disp))
    h_fig=[];
    return;
end


tt=p.Results.Name;

switch reg_obj.Cell_w_unit
    case 'pings'
        x_disp=nanmean(output_reg.Ping_S,1);
    case 'meters'
        x_disp=(nanmean(output_reg.Dist_S,1)+nanmean(output_reg.Dist_E,1))/2;
end


y_disp=nanmean((output_reg.Range_ref_min+output_reg.Range_ref_max)/2,2);

mat_size=size(sv_disp);
h_fig=new_echo_figure(p.Results.main_figure,'Name',tt,'Tag',[tt reg_obj.tag_str()],...
    'Units','Normalized','Position',[0.1 0.2 0.8 0.6],'Group','Regions','Windowstyle','Docked','CloseRequestFcn',@close_reg_fig);
ax_in=axes('Parent',h_fig,'Units','Normalized','position',[0.2 0.25 0.7 0.65],'xticklabel',{},'yticklabel',{},'nextplot','add','box','on');
title(ax_in,tt);


if  ~any(mat_size==1)
    reg_plot=pcolor(ax_in,repmat(x_disp,length(y_disp),1),repmat(y_disp,1,length(x_disp)),sv_disp);
    set(reg_plot,'alphadata',alphadata,'facealpha','flat','edgecolor','none');
end
%shading(ax_in,'interp')
ax_in.XTick=(x_disp(1):reg_obj.Cell_w:x_disp(end));
ax_in.YTick=sort((y_disp(1):reg_obj.Cell_h:y_disp(end)));
caxis(ax_in,cax);

colorbar(ax_in,'Position',[0.92 0.25 0.03 0.65]);

[cmap,~,~,col_grid,~,~]=init_cmap(cmap_name);
colormap(ax_in,cmap);
set(ax_in,'GridColor',col_grid);
grid(ax_in,'on');

axis(ax_in,'ij');



ax_horz=axes('Parent',h_fig,'Units','Normalized','position',[0.2 0.1 0.7 0.15],'nextplot','add','box','on');
plot(ax_horz,x_disp,pow2db_perso(nanmean(output_reg.Sv_mean_lin_esp2,1)),'r');
grid(ax_horz,'on');
xlabel(ax_horz,sprintf('%s',reg_obj.Cell_w_unit))
ylabel(ax_horz,'Sv mean(dB)')

%ax_horz.XTick=(x_disp(1):reg_obj.Cell_w*10:x_disp(end));
ax_horz.XTickLabelRotation=90;

switch reg_obj.Cell_w_unit
    case 'meters'
        ax_horz.XAxis.TickLabelFormat='%.0fm';
    case 'pings'
        ax_horz.XAxis.TickLabelFormat='%.0f';
end

ax_vert=axes('Parent',h_fig,'Units','Normalized','position',[0.05 0.25 0.15 0.65],'xaxislocation','top','nextplot','add','box','on');
plot(ax_vert,pow2db_perso(nanmean(output_reg.Sv_mean_lin_esp2,2)),y_disp,'r');
xlabel(ax_vert,'Sv mean (db)')
axis(ax_vert,'ij');
switch reg_obj.Reference
    case 'Surface'
         ylabel(ax_vert,sprintf('Depth (%s)',reg_obj.Cell_h_unit));
    case 'Bottom'
        ylabel(ax_vert,sprintf('Above bottom(%s)',reg_obj.Cell_h_unit));
    case 'Line'
        ylabel(ax_vert,sprintf('From line (%s)',reg_obj.Cell_h_unit));  
end

grid(ax_vert,'on');
%ax_vert.YTick=(y_disp(1):reg_obj.Cell_h:y_disp(end))+reg_obj.Cell_h/2;

ax_vert.YAxis.TickLabelFormat='%.0gm';
linkaxes([ax_in ax_vert],'y');
linkaxes([ax_in ax_horz],'x');
set(ax_in,'Xlim',[nanmin(x_disp)-reg_obj.Cell_w/2 nanmax(x_disp)+reg_obj.Cell_w/2]);
set(ax_in,'Ylim',[nanmin(y_disp)-reg_obj.Cell_h/2 nanmax(y_disp)+reg_obj.Cell_h/2]);

    function close_reg_fig(src,~,~)
        try
            delete(cmap_list) ;
            delete(cax_list) ;
        end
        delete(src)
    end

    function listenCmapReg(src,evt)
        [cmap,~,~,col_grid,~,~]=init_cmap(evt.AffectedObject.Cmap);
        colormap(ax_in,cmap);
    end

    function listenCaxReg(src,evt)
        cax=evt.AffectedObject.getCaxField('sv');
        caxis(ax_in,cax);
        alphadata=double(sv_disp>cax(1));
        set(reg_plot,'alphadata',alphadata)
    end

end

