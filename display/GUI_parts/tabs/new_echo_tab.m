function tab_handle=new_echo_tab(main_figure_handle,parent_tab_group,varargin)


p = inputParser;
addRequired(p,'main_figure_handle',@(x) isa(x,'matlab.ui.Figure'));
addRequired(p,'parent_tab_group',@(x) isa(x,'matlab.ui.container.TabGroup'));
addParameter(p,'Title','',@ischar);
addParameter(p,'UiContextMenuName','',@ischar);

parse(p,main_figure_handle,parent_tab_group,varargin{:});

tab_handle=uitab(parent_tab_group,'Title',p.Results.Title,'Tag',p.Results.UiContextMenuName,'BackGroundColor','w');

if ~isempty(p.Results.UiContextMenuName)
    tab_menu=create_context_menu_tabs(main_figure_handle,parent_tab_group,p.Results.UiContextMenuName);
    tab_handle.UIContextMenu=tab_menu;
end

tab_handle.Parent.SelectedTab=tab_handle;