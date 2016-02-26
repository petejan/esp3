function display_map_input_cl(obj_tot,varargin)
p = inputParser;

addRequired(p,'obj_tot',@(x) isa(x,'map_input_cl'));
addParameter(p,'hfig',[],@(h) isempty(h)|isa(h,'matlab.ui.Figure'));
addParameter(p,'main_figure',[],@(h) isempty(h)|isa(h,'matlab.ui.Figure'));
addParameter(p,'field','SliceAbscf',@ischar);

parse(p,obj_tot,varargin{:});
hfig=p.Results.hfig;
main_figure=p.Results.main_figure;
field=p.Results.field;


if isempty(hfig)
    hfig=figure();
end



snap=[];
%col_snap={'r','b','g','k','m'};
col_snap={'k'};


set(hfig,'Name','Navigation','NumberTitle','off','tag','nav');

LonLim=[nan nan];
LatLim=[nan nan];

for uuobj=1:length(obj_tot)
    obj=obj_tot(uuobj);
    snap=union(snap,unique(obj.Snapshot));
    LonLim(1)=nanmin(LonLim(1),obj.LonLim(1));
    LonLim(2)=nanmax(LonLim(2),obj.LonLim(2));
    LatLim(1)=nanmin(LatLim(1),obj.LatLim(1));
    LatLim(2)=nanmax(LatLim(2),obj.LatLim(2));
end

nb_row=ceil(length(snap)/3);
nb_col=nanmin(length(snap),3);
% ax_pos=get(ax,'position');
%
% dcol=ax_pos(3)/nb_col;
% drow=ax_pos(4)/nb_row;

% fig=get(ax,'parent');
% delete(ax);
n_ax=gobjects(length(snap),1);
figure(hfig);

for usnap=1:length(snap)
    %     n_ax(usnap)=axes('parent',fig);
    %     idx_r=ceil(usnap/nb_col);
    %     idx_c=usnap-nb_col*(idx_r-1);
    %     set(n_ax(usnap),'position',[ax_pos(1)+dcol*(idx_c-1) ax_pos(2)+drow*(idx_r-1) dcol drow]);
    n_ax(usnap)=subplot(nb_row,nb_col,usnap);
    proj=m_getproj;
    list_proj_str={proj(:).name};
    sucess=0;
    i=0;
    while sucess==0&&i<length(list_proj_str);
        try
            m_proj(obj.Proj,'long',LonLim,'lat',LatLim);
            sucess=1;
        catch
            i=i+1;
            fprintf(1,'Can''t use %s projection inside this area... Trying %s\n',obj.Proj,list_proj_str{i});
            obj.Proj=list_proj_str{i};
            if i==length(list_proj_str)
                fprintf(1,'Could not find any appropriate projection\n');
                return
            end
        end
    end
    
    axes(n_ax(usnap));
    hold on;
    
    
    %     context_menu=uicontextmenu;
    %     n_ax(usnap).UIContextMenu=context_menu;
    %     uimenu(context_menu,'Label','Copy Axes to new Figure','Callback',{@copy_axes_callback});
    %
    try
        m_grid('box','fancy','tickdir','in');
    catch
        fprintf(1,'Area to small to display Navigation\n');
        return;
    end
    
    try
        if obj.Coast>0
            m_gshhs_h('patch',[.5 .5 .5],'edgecolor','k');
        end
    catch
        disp('No Geographical data available...')
    end
    
    if obj.Depth_Contour>0
        try
            [Cs,hs]=m_elev('contour',-10000:obj.Depth_Contour:-1,'edgecolor',[.4 .4 .4],'visible','on');
            clabel(Cs,hs,'fontsize',8);
        catch
            disp('No Bathymetric data available...')
        end
    end
end

for uuobj=1:length(obj_tot)
    
    obj=obj_tot(uuobj);
    str=cell(1,length(obj.Transect));
    str_disp=cell(1,length(obj.Transect));
    for i=1:length(obj.Transect)
        if iscell(obj.Filename{i})
            str_temp=sprintf('%s\n',obj.Filename{i}{:});
            str_temp=str_temp(1:end-1);
        else
            str_temp=obj.Filename{i};
        end
        if ~isempty(obj.Stratum{i})
            
            str{i}=sprintf('File %s\n Stratum %d\n Transect %d\n',...
                str_temp,obj.Stratum{i},obj.Transect(i));
            str_disp{i}=sprintf('St %d T %d',...
                obj.Stratum{i},obj.Transect(i));
            
            if obj.Snapshot(i)==0&&strcmp(obj.Stratum(i),' ')&&obj.Transect(i)==0
                str_disp{i}='';
                str{i}=obj.Filename{i};
            end
        else
            str_disp{i}='';
            str{i}=obj.Filename{i};
        end
        
    end
    
    u_plot=gobjects(1,length(obj.Snapshot));
    u_plot_slice=gobjects(1,length(obj.Snapshot));
    
    for usnap=1:length(snap)
        idx_snap=find(obj.Snapshot==snap(usnap));
        
        if isempty(idx_snap)
            continue;
        end
        axes(n_ax(usnap));
        hold on;
        title(sprintf('%s\n Snapshot %d',obj.Trip{idx_snap(1)},snap(usnap)));
        
        for uui=1:length(idx_snap)
            if ~isempty(obj.Lon{idx_snap(uui)})
                u_plot(idx_snap(uui))=m_plot(obj.Lon{idx_snap(uui)},obj.Lat{idx_snap(uui)},'color','b','linewidth',2,'tag','nav');
                set(u_plot(idx_snap(uui)),'ButtonDownFcn',{@disp_line_name_callback,str{idx_snap(uui)}});
                if~isempty(main_figure)
                    create_context_menu_line(main_figure,u_plot(idx_snap(uui)),obj.PathToFile{idx_snap(uui)},obj.Filename{idx_snap(uui)});
                end
                if obj.Transect(idx_snap(uui))>0
                    m_text(obj.Lon{idx_snap(uui)}(1),obj.Lat{idx_snap(uui)}(1),num2str(obj.Transect(idx_snap(uui)),'%.0f'),'Fontsize',16,'Fontweight','Bold','Color','b');
                end
            end
            
            if ~isempty(obj.SliceLon{idx_snap(uui)})
                if isempty(obj.Lon{idx_snap(uui)})
                    m_text(obj.SliceLon{idx_snap(uui)}(1),obj.SliceLat{idx_snap(uui)}(1),num2str(obj.Transect(idx_snap(uui)),'%.0f'),'Fontsize',16,'Fontweight','Bold','Color','r');
                end
                u_plot_slice(idx_snap(uui))=m_plot(obj.SliceLon{idx_snap(uui)},obj.SliceLat{idx_snap(uui)},'xb');
                set(u_plot_slice(idx_snap(uui)),'ButtonDownFcn',{@disp_line_name_callback,str{idx_snap(uui)}});
                if~isempty(main_figure)
                    create_context_menu_line(main_figure,u_plot_slice(idx_snap(uui)),obj.PathToFile{idx_snap(uui)},obj.Filename{idx_snap(uui)});
                end
                ring_size=obj.Rmax*sqrt(obj.(field){idx_snap(uui)}/obj.ValMax);
                idx_rings=find(ring_size>0);
                for uuj=idx_rings
                    m_range_ring(obj.SliceLon{idx_snap(uui)}(uuj),obj.SliceLat{idx_snap(uui)}(uuj),ring_size(uuj),'color',col_snap{rem(usnap,length(col_snap))+1},'linewidth',1.5);
                end
            end
        end
        
    end
    linkaxes(n_ax,'x');
end

if~isempty(main_figure)
    set(hfig,'WindowButtonDownFcn',{@copy_axes_callback,main_figure});
else
    set(hfig,'WindowButtonDownFcn',{@copy_axes_callback});
end


Map_info.Proj=obj.Proj;
Map_info.LonLim=LonLim;
Map_info.LatLim=LatLim;
setappdata(hfig,'Map_info',Map_info);
end




function disp_line_name_callback(src,~,name)

ax=get(src,'parent');
cp=ax.CurrentPoint;
x = cp(1,1);
y=cp(1,2);

u = findobj(ax,'Tag','name');
delete(u);

axes(ax);
text(x,y,name,'tag','name');


lines = findobj(ax,'Type','Line','tag','nav');
for il=1:length(lines)
    if lines(il)==src
        set(lines(il),'color','r');
    else
        set(lines(il),'color','b');
    end
    
end

end


function create_context_menu_line(main_figure,line,pathtofile,files)

context_menu=uicontextmenu;
line.UIContextMenu=context_menu;
uimenu(context_menu,'Label','Go to this layer','Callback',{@activate_line_callback,main_figure,pathtofile,files});
uimenu(context_menu,'Label','Edit Survey Data','Callback',{@edit_survey_data_line_callback,main_figure,pathtofile,files});

end

function activate_line_callback(src,~,main_figure,pathtofile,files)
layers=getappdata(main_figure,'Layers');
if~isempty(layers)
    [idx,found]=layers.find_layer_idx_files_path(pathtofile,files);
    
else
    found=0;
end
if found==1
    layer=layers(idx(1));
    setappdata(main_figure,'Layer',layer);
    update_display(main_figure,1);
else
    choice = questdlg('We cannot find the transect you are pointing at... Do you want to load it?', ...
        'Incomplete',...
        'Yes','No',...
        'Yes');
    % Handle response
    switch choice
        case 'Yes'
            files_to_open=cell(1,length(files));
            if ~isempty(pathtofile)
                for ifi=1:length(files)
                    files_to_open{ifi}=fullfile(pathtofile,files{ifi});
                end
            else
                return;
            end
            open_file([],[],files_to_open,main_figure);
        case 'No'
        otherwise
            return;
    end
    
end
end

function edit_survey_data_line_callback(~,~,main_figure,pathtofile,files)
layers=getappdata(main_figure,'Layers');

if~isempty(layers)
    [idx,found]=layers.find_layer_idx_files_path(pathtofile,files);
else
    found=0;
end

if found==0
    choice = questdlg('We cannot find the transect you are pointing at... Do you want to load it?', ...
        'Incomplete',...
        'Yes','No',...
        'Yes');
    % Handle response
    switch choice
        case 'Yes'
            files_to_open=cell(1,length(files));
            if ~isempty(pathtofile)
                for ifi=1:length(files)
                    files_to_open{ifi}=fullfile(pathtofile,files{ifi});
                end
            else
                return;
            end
            open_file([],[],files_to_open,main_figure);
        case 'No'
        otherwise
            return;
    end
    layers=getappdata(main_figure,'Layers');
    
    if~isempty(layers)
        [idx,found]=layers.find_layer_idx_files_path(pathtofile,files);
    else
        found=0;
    end
    if found==0
        disp('We tried to load the files but this does not work...');
        return;
    end
    
end
layer=layers(idx(1));
new_surveydata=layer.get_survey_data();
[new_surveydata.Voyage,new_surveydata.SurveyName,new_surveydata.Snapshot,new_surveydata.Stratum,new_surveydata.Transect,cancel]=fill_survey_data_dlbox(new_surveydata,'title','Enter New Survey Data');
if cancel>0
    return;
end
layer.set_survey_data(new_surveydata);
layer.update_echo_logbook_file();
setappdata(main_figure,'Layer',layer);
update_display(main_figure,1);
end


