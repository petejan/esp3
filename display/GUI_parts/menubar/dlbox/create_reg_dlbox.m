%% create_reg_dlbox.m
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
% * |main_figure|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-07-31: revamped to allow ymin and ymax. Aesthetics changed. Commented (Alex)
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
function create_reg_dlbox(~,~,main_figure)

layer = getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

reg_fig_comp = getappdata(main_figure,'reg_fig');


%% Main Window

reg_fig = new_echo_figure(main_figure, ...
    'Units','pixels',...
    'Position',[100 100 400 300],...
    'Resize','off',...
    'Name','Create WC Region',...
    'Tag','create_reg');

% Window title
uicontrol(reg_fig, ...
    'Style','text',...
    'BackgroundColor','white',...
    'Units','normalized',...
    'Position',[0.2 0.85 0.6 0.1],...
    'fontsize',14,...
    'String','Create WC Region');



%% Reference

% possible values and default
ref = {'Surface','Bottom'};
ref_idx = 1;

% text
uicontrol(reg_fig,...
    'Style','Text',...
    'BackgroundColor','white',...
    'String','Reference (Ref):',...
    'units','normalized',...
    'HorizontalAlignment','right',...
    'Position',[0 0.70 0.26 0.07]);

% value
reg_fig_comp.tog_ref = uicontrol(reg_fig,...
    'Style','popupmenu',...
    'String',ref,...
    'Value',ref_idx,...
    'units','normalized',...
    'Position',[0.27 0.68 0.2 0.1]);


%% Region type

% possible values and default
data_type = {'Data' 'Bad Data'};
data_idx = 1;

% text
uicontrol(reg_fig,...
    'Style','Text',...
    'String','Data Type (Type):',...
    'units','normalized',...
    'HorizontalAlignment','right',...
    'BackgroundColor','white',...
    'Position',[0.5 0.70 0.27 0.07]);

% value
reg_fig_comp.data_type = uicontrol(reg_fig,...
    'Style','popupmenu',...
    'String',data_type,...
    'Value',data_idx,...
    'units','normalized',...
    'Position',[0.78 0.68 0.2 0.1]);




%% Ymin and Ymax

text_top_position = [0 0.55 0.6 0.07];
value_top_position = [0.62 0.555 0.1 0.07];
text_bottom_position = [0 0.45 0.6 0.07];
value_bottom_position = [0.62 0.457 0.1 0.07];

% ymin text
reg_fig_comp.str_y_min = uicontrol(reg_fig,...
    'Style','Text',...
    'BackgroundColor','white',...
    'String','Y min:',...
    'units','normalized',...
    'HorizontalAlignment','right',...
    'Position',text_top_position);

% ymin value
reg_fig_comp.y_min = uicontrol(reg_fig,...
    'Style','edit',...
    'unit','normalized',...
    'position',value_top_position,...
    'string',0,...
    'Tag','w');


% ymax text
reg_fig_comp.str_y_max = uicontrol(reg_fig,...
    'Style','Text',...
    'BackgroundColor','white',...
    'String','Y max:',...
    'units','normalized',...
    'HorizontalAlignment','right',...
    'Position',text_bottom_position);

% ymax value
reg_fig_comp.y_max = uicontrol(reg_fig,...
    'Style','edit',...
    'unit','normalized',...
    'position',value_bottom_position,...
    'string',inf,...
    'Tag','w');

% set proper text and position depending on reference
switch ref{ref_idx}
    case 'Surface'
        
        % set(reg_fig_comp.str_surf,'String','Min Depth(m)');
        
        % put ymin ontop
        set(reg_fig_comp.str_y_min,'Position',text_top_position);
        set(reg_fig_comp.y_min,'position',value_top_position);
        set(reg_fig_comp.str_y_max,'Position',text_bottom_position);
        set(reg_fig_comp.y_max,'position',value_bottom_position);
        
        % set proper texts
        set(reg_fig_comp.str_y_min,'String','Min depth below surface in m (y_min):');
        set(reg_fig_comp.str_y_max,'String','Max depth below surface in m (y_max):');
        

    case 'Bottom'
        
        % set(reg_fig_comp.str_surf,'String','Height Above Bottom (m)');
        
        % put ymax ontop
        set(reg_fig_comp.str_y_max,'Position',text_top_position);
        set(reg_fig_comp.y_max,'position',value_top_position);
        set(reg_fig_comp.str_y_min,'Position',text_bottom_position);
        set(reg_fig_comp.y_min,'position',value_bottom_position);
        
        % set proper texts
        set(reg_fig_comp.str_y_min,'String','Min height above bottom in m (y_min):');
        set(reg_fig_comp.str_y_max,'String','Max height above bottom in m (y_max):');
   
end



%% Cell width

% possible values and default
units_w = {'pings','meters'};
w_unit_idx = 1;

% text
uicontrol(reg_fig,...
    'Style','Text',...
    'BackgroundColor','white',...
    'String','Cell Width (Cell_w):',...
    'units','normalized',...
    'HorizontalAlignment','right',...
    'Position',[0 0.30 0.35 0.07]);

% value
reg_fig_comp.cell_w = uicontrol(reg_fig,...
    'Style','edit',...
    'unit','normalized',...
    'position',[0.36 0.305 0.15 0.07],...
    'string',10,...
    'Tag','w');

% unit
reg_fig_comp.cell_w_unit = uicontrol(reg_fig,...
    'Style','popupmenu',...
    'String',units_w,...
    'Value',w_unit_idx,...
    'units','normalized',...
    'Position',[0.52 0.28 0.2 0.1],...
    'Tag','w');

%% cell height

% possible values and default
units_h = {'meters','samples'};
h_unit_idx = 1;

% text
uicontrol(reg_fig,...
    'Style','Text',...
    'BackgroundColor','white',...
    'String','Cell Height (Cell_h):',...
    'units','normalized',...
    'HorizontalAlignment','right',...
    'Position',[0 0.2 0.35 0.07]);

% value
reg_fig_comp.cell_h = uicontrol(reg_fig,...
    'Style','edit',...
    'unit','normalized',...
    'position',[0.36 0.205 0.15 0.07],...
    'string',10,...
    'Tag','h');

% unit
reg_fig_comp.cell_h_unit = uicontrol(reg_fig,...
    'Style','popupmenu',...
    'String',units_h,...
    'Value',h_unit_idx,...
    'units','normalized',...
    'Position',[0.52 0.18 0.2 0.1],...
    'Tag','h');



%% "Create Region" button
uicontrol(reg_fig,...
    'Style','pushbutton',...
    'units','normalized',...
    'string','Create Region',...
    'pos',[0.35 0.05 0.25,0.1],...
    'TooltipString','Create Region',...
    'HorizontalAlignment','left',...
    'BackgroundColor','white',...
    'callback',{@create_reg_callback,reg_fig_comp,main_figure,reg_fig});

%% Callbacks:
set(reg_fig_comp.y_min,'callback',@check_y_callback)
set(reg_fig_comp.y_max,'callback',@check_y_callback)
set(reg_fig_comp.tog_ref,'callback',{@change_ref_callback,reg_fig_comp})
set([reg_fig_comp.cell_w reg_fig_comp.cell_h],'callback',{@check_cell,main_figure})


%% make window visible
set(reg_fig,'visible','on');


end

%% Create Region button callback
function create_reg_callback(~,~,reg_fig_comp,main_figure,reg_fig)

layer = getappdata(main_figure,'Layer');

curr_disp = getappdata(main_figure,'Curr_disp');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);
if isempty(trans_obj)
    return;
end


ref = get(reg_fig_comp.tog_ref,'String');
ref_idx = get(reg_fig_comp.tog_ref,'value');

data_type = get(reg_fig_comp.data_type,'String');
data_type_idx = get(reg_fig_comp.data_type,'value');

h_units = get(reg_fig_comp.cell_h_unit,'String');
h_units_idx = get(reg_fig_comp.cell_h_unit,'value');

w_units = get(reg_fig_comp.cell_w_unit,'String');
w_units_idx = get(reg_fig_comp.cell_w_unit,'value');

y_min = str2double(get(reg_fig_comp.y_min,'string'));
y_max = str2double(get(reg_fig_comp.y_max,'string'));

% -- OLD CODE using only one field instead of two for y_min/y_max
% switch ref{ref_idx}
%     case 'Surface'
%         y_min = str2double(get(reg_fig_comp.depth_info,'string'));
%         y_max = Inf;
%     case 'Bottom'
%         y_min = 0;
%         y_max = str2double(get(reg_fig_comp.depth_info,'string'));
% end

% create the WC region in trans object
reg_wc = trans_obj.create_WC_region(...
    'y_min',y_min,...
    'y_max',y_max,...
    'Type',data_type{data_type_idx},...
    'Ref',ref{ref_idx},...
    'Cell_w',str2double(get(reg_fig_comp.cell_w,'string')),...
    'Cell_h',str2double(get(reg_fig_comp.cell_h,'string')),...
    'Cell_w_unit',w_units{w_units_idx},...
    'Cell_h_unit',h_units{h_units_idx});

trans_obj.add_region(reg_wc);

close(reg_fig);


display_regions(main_figure,'both');

curr_disp = getappdata(main_figure,'Curr_disp');

trans_obj = layer.get_trans(curr_disp);

curr_disp.Active_reg_ID = trans_obj.get_reg_first_Unique_ID();

order_stacks_fig(main_figure);

end

function check_y_callback(src,~)

% get value
val = str2double(get(src,'String'));

% if value is non-numeric. Put back to default
if isnan(val)
    set(src,'string',num2str(5));
end

% if value is negative. Put back to default
if val<0
    set(src,'string',num2str(5));
end

end

%% Change reference callback
function change_ref_callback(src,~,reg_fig_comp)


text_top_position = [0 0.55 0.6 0.07];
value_top_position = [0.62 0.555 0.1 0.07];
text_bottom_position = [0 0.45 0.6 0.07];
value_bottom_position = [0.62 0.457 0.1 0.07];


ref = get(reg_fig_comp.tog_ref,'String');
ref_idx = get(reg_fig_comp.tog_ref,'value');


% set proper text and position depending on reference
switch ref{ref_idx}
    case 'Surface'
        
        % set(reg_fig_comp.str_surf,'String','Min Depth(m)');
        
        % put ymin ontop
        set(reg_fig_comp.str_y_min,'Position',text_top_position);
        set(reg_fig_comp.y_min,'position',value_top_position);
        set(reg_fig_comp.str_y_max,'Position',text_bottom_position);
        set(reg_fig_comp.y_max,'position',value_bottom_position);
        
        % set proper texts
        set(reg_fig_comp.str_y_min,'String','Min depth below surface in m (y_min):');
        set(reg_fig_comp.str_y_max,'String','Max depth below surface in m (y_max):');
        

    case 'Bottom'
        
        % set(reg_fig_comp.str_surf,'String','Height Above Bottom (m)');
        
        % put ymax ontop
        set(reg_fig_comp.str_y_max,'Position',text_top_position);
        set(reg_fig_comp.y_max,'position',value_top_position);
        set(reg_fig_comp.str_y_min,'Position',text_bottom_position);
        set(reg_fig_comp.y_min,'position',value_bottom_position);
        
        % set proper texts
        set(reg_fig_comp.str_y_min,'String','Min height above bottom in m (y_min):');
        set(reg_fig_comp.str_y_max,'String','Max height above bottom in m (y_max):');
   
end


end