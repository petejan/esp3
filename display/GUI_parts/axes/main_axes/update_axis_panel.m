function update_axis_panel(main_figure,new)
layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

if any(~isvalid([axes_panel_comp.main_echo axes_panel_comp.main_axes]))
    load_axis_panel(main_figure,axes_panel_comp.axes_panel); 
    axes_panel_comp=getappdata(main_figure,'Axes_panel');
end

if new==0
    try
        x=double(get(axes_panel_comp.main_axes,'xlim'));
        y=double(get(axes_panel_comp.main_axes,'ylim'));
    catch
        x=[0 0];
        y=[0 0];
    end

else
    x=[0 0];
    y=[0 0];
    
    u=findobj(axes_panel_comp.main_axes,'Tag','SelectLine','-or','Tag','SelectArea');
    delete(u);
end

[trans_obj,~]=layer.get_trans(curr_disp);

if isempty(trans_obj)
    idx_freq=1;
    curr_disp.ChannelID=layer.ChannelID{idx_freq};  
    return;
end

[~,found]=find_field_idx(trans_obj.Data,curr_disp.Fieldname);

if found==0
    [~,found]=find_field_idx(trans_obj.Data,'sv');
    if found==0
        field=trans_obj.Data.Fieldname{1};
    else
        field='sv';
    end
    
    curr_disp.setField(field);
    setappdata(main_figure,'Curr_disp',curr_disp);
    return;
end

delete(axes_panel_comp.listeners);
clear_lines(axes_panel_comp.main_axes);

[dr,dp]=layer.display_layer(curr_disp,curr_disp.Fieldname,axes_panel_comp.main_axes,axes_panel_comp.main_echo,x,y,new);

if new
   curr_disp.R_disp=get(axes_panel_comp.main_axes,'YLim');
end

str_subsampling=sprintf('Disp. SubSampling: [%.0fx%.0f]',dp,dr);
info_panel_comp=getappdata(main_figure,'Info_panel');

if dr>1||dp>1
  set(info_panel_comp.display_subsampling,'String',str_subsampling,'ForegroundColor','r','Fontweight','bold');
else
    set(info_panel_comp.display_subsampling,'String',str_subsampling,'ForegroundColor',[0 0.5 0],'Fontweight','normal');
end


% if strcmpi(curr_disp.CursorMode,'Normal')  
%     create_context_menu_main_echo(main_figure);
% end

axes_panel_comp.listeners=addlistener(axes_panel_comp.main_axes,'YLim','PostSet',@(src,envdata)listenYLim(src,envdata,main_figure)); 
setappdata(main_figure,'Axes_panel',axes_panel_comp);
update_grid(main_figure);
end