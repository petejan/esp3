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

%% input variable management

p = inputParser;

% default values
field_def='sv';
TS_def=-52;
[cax_d,~,~]=init_cax(field_def);
addRequired(p,'reg_obj',@(obj) isa(obj,'region_cl'));
addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl')|isstruct(obj));
addParameter(p,'line_obj',[],@(x) isa(x,'line_cl')||isempty(x));
addParameter(p,'Name',reg_obj.print(),@ischar);
addParameter(p,'Cax',cax_d,@isnumeric);
addParameter(p,'Cmap','jet',@ischar);
addParameter(p,'alphadata',[],@isnumeric);
addParameter(p,'field',field_def,@ischar);
addParameter(p,'TS',TS_def,@isnumeric);
addParameter(p,'main_figure',[],@(h) isempty(h)|ishghandle(h));
addParameter(p,'parent',[],@(h) isempty(h)|ishghandle(h));
addParameter(p,'load_bar_comp',[]);

parse(p,reg_obj,trans_obj,varargin{:});

%%

h_fig=p.Results.parent;

field= p.Results.field;
if isa(trans_obj,'transceiver_cl')
           %profile on;
    %      output_reg_old=trans_obj.integrate_region(reg_obj);
%profile on;
    %output_reg_old=trans_obj.integrate_region_v4(reg_obj,'line_obj',p.Results.line_obj,'denoised',1); 
     output_reg=trans_obj.integrate_region_v5(reg_obj,'line_obj',p.Results.line_obj,'denoised',1,'load_bar_comp',p.Results.load_bar_comp);

%      profile off;
%      profile viewer;
% output_reg_old=trans_obj.integrate_region_v4(reg_obj,'line_obj',p.Results.line_obj,'denoised',1); 
% output_reg_old=trans_obj.integrate_region_v3(reg_obj,'line_obj',p.Results.line_obj,'denoised',1); 
% compare_reg_output(output_reg,output_reg_old,reg_obj.Reference);
  
    tt=sprintf('%s %s %.0f kHz ' ,field,p.Results.Name,trans_obj.Params.FrequencyStart(1)/1e3 );
    
else
    output_reg=trans_obj;
    tt=sprintf('%s %s' ,field,p.Results.Name );
    
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

%% getting data to display
switch field
    case 'fishdensity'
        var_disp=db2pow_perso((pow2db_perso(output_reg.Sv_mean_lin)-p.Results.TS));
        var_lin=(var_disp);
        var_scale='lin';
        ylab='(number/m3)';
    case {'sv' 'sp' 'spdenoised' 'svdenoised'}
        var_disp=pow2db_perso(output_reg.Sv_mean_lin);
        var_lin=db2pow_perso(var_disp);
        var_scale='db';
        ylab='dB';
end

%% color bounds and cmap
if ~isempty(curr_disp)
    if ismember('Cax',p.UsingDefaults)
        cax=curr_disp.getCaxField(field);
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

%% remove data outside colour scale through alpha
if ~ismember('alphadata',p.UsingDefaults)&&all(size(var_disp)==size(p.Results.alphadata))
    alphadata=p.Results.alphadata;
else
    alphadata=double(var_disp>cax(1));
end

if ~any(~isnan(var_disp))
    h_fig=[];
    return;
end

%% X and Y disp
switch reg_obj.Cell_w_unit
    case 'pings'
        x_disp=output_reg.Ping_S;
    case 'meters'
        x_disp=(output_reg.Dist_S+output_reg.Dist_E)/2;
     case 'seconds'
        x_disp=((output_reg.Time_S+output_reg.Time_E)/2-output_reg.Time_S(1))*24*60*60;       
end



%% create new figure here
if isempty(h_fig)
h_fig=new_echo_figure(p.Results.main_figure,'Name',tt,'Tag',[tt reg_obj.tag_str()],...
    'Units','normalized','Position',[0.1 0.2 0.8 0.6],'Group','Regions','Windowstyle','Docked');
end
%% main region display

% axes
ax_in=axes('Parent',h_fig,'Units','Normalized','position',[0.2 0.25 0.7 0.65],'xticklabel',{},'yticklabel',{},'nextplot','add','box','on','TickLength',[0 0],'GridAlpha',0.05);

% title
title(ax_in,tt);

switch reg_obj.Reference
    case 'Surface'
        y_disp=(output_reg.Range_ref_max);
    case {'Bottom','Line'}
        
        y_disp=-(output_reg.Range_ref_max);
end

% data

mat_size=size(var_disp);
if  ~any(mat_size==1)
    reg_plot=pcolor(ax_in,repmat(x_disp,size(y_disp,1),1),y_disp,var_disp);
    set(reg_plot,'alphadata',alphadata,'facealpha','flat','edgecolor','none','AlphaDataMapping','none');
end
ymin=nanmin(y_disp(:));
ymax=nanmax(y_disp(:));

xmin=nanmin(x_disp);
xmax=nanmax(x_disp);

% ticks and grid

ax_in.XTick=unique(x_disp(~isnan(x_disp)));
ax_in.YTick=sort((ymin:reg_obj.Cell_h:ymax));

grid(ax_in,'on');

% colour
caxis(ax_in,cax);
colorbar(ax_in,'Position',[0.92 0.25 0.03 0.65]);
[cmap,col_ax,~,col_grid,~,~]=init_cmap(cmap_name);
colormap(ax_in,cmap);
set(ax_in,'GridColor',col_grid,'Color',col_ax);

%% linear or dB scales for bottom and side displays

switch var_scale
    case 'lin'
        horz_plot=nanmean(var_lin,1);
        vert_plot=nanmean(var_lin,2);
    case 'db'
        horz_plot=pow2db_perso(nanmean(var_lin,1));
        vert_plot=pow2db_perso(nanmean(var_lin,2));
end

%% bottom display

% axes
ax_horz=axes('Parent',h_fig,'Units','Normalized','position',[0.2 0.1 0.7 0.15],'nextplot','add','box','on');

% data
plot(ax_horz,x_disp,horz_plot,'r');

% grid, labels, ticks, etc
grid(ax_horz,'on');
xlabel(ax_horz,sprintf('%s',reg_obj.Cell_w_unit))
ylabel(ax_horz,ylab)
%ax_horz.XTick=get(ax_in,'XTick');
ax_horz.XTickLabelRotation=45;

switch reg_obj.Cell_w_unit
    case 'meters'
        ax_horz.XAxis.TickLabelFormat='%.0fm';
    case {'pings' 'seconds'}
        ax_horz.XAxis.TickLabelFormat='%.0f';
end

ax_horz.XAxis.ExponentMode='manual';
ax_horz.XAxis.Exponent=0;
%% side display

% axes
ax_vert=axes('Parent',h_fig,'Units','Normalized','position',[0.05 0.25 0.15 0.65],'xaxislocation','top','nextplot','add','box','on','DeleteFcn',@delete_axes);

% data
plot(ax_vert,vert_plot,y_disp,'r');

% grid, labels, ticks, etc
xlabel(ax_vert,ylab)


switch reg_obj.Reference
    case 'Surface'
        ylabel(ax_vert,'Depth (m)');
        axis(ax_in,'ij');
        axis(ax_vert,'ij');
    case 'Bottom'
        ylabel(ax_vert,'Distance Above bottom(m)');
    case 'Line'
        ylabel(ax_vert,'Distance From line (m)');
        
end

grid(ax_vert,'on');
%ax_vert.YTick=get(ax_in,'YTick');
ax_vert.YAxis.TickLabelFormat='%.0gm';

%% link axes of main display and bottom/side plots
linkaxes([ax_in ax_vert],'y');
linkaxes([ax_in ax_horz],'x');


%% final adjust axes
set(ax_in,'Xlim',[xmin-reg_obj.Cell_w/2 xmax+reg_obj.Cell_w/2]);
set(ax_in,'Ylim',[ymin-reg_obj.Cell_h/2 ymax+reg_obj.Cell_h/2]);

%% nest functions

% Figure close request callback for region display
    function delete_axes(src,~)
        if ~isdeployed
            disp('delete_axes reg listeners')
        end
        delete(cmap_list) ;
        delete(cax_list) ;
        delete(src);
    end

% Listener for colourmap
    function listenCmapReg(src,evt)
        if ~isdeployed
            disp('listenCmapReg')
        end
        [cmap,col_ax,~,col_grid,~,~]=init_cmap(evt.AffectedObject.Cmap);
        try
            if isvalid(ax_in)
                colormap(ax_in,cmap);
                set(ax_in,'GridColor',col_grid,'Color',col_ax);
            end
        end
    end

% Listener for alpha values to limit data shown
    function listenCaxReg(src,evt)
        cax=evt.AffectedObject.getCaxField(field);
        if ~isdeployed
            disp('listenCaxReg')
        end
        if exist('ax_in','var')>0
            
            if isvalid(ax_in)
                caxis(ax_in,cax);
                alphadata=double(var_disp>cax(1));
                set(reg_plot,'alphadata',alphadata)
            end
        end
    end

end

