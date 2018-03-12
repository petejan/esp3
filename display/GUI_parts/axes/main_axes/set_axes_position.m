function set_axes_position(main_figure)
main_menu=getappdata(main_figure,'main_menu');
axes_panel_comp=getappdata(main_figure,'Axes_panel');

state_colorbar=get(main_menu.show_colorbar,'checked');
% state_xaxes=get(main_menu.show_xaxes,'checked');
% state_yaxes=get(main_menu.show_yaxes,'checked');
state_haxes=get(main_menu.show_haxes,'checked');
state_vaxes=get(main_menu.show_vaxes,'checked');

pos=[0 0 1 1];
vpos=[-0.05 0 0.05 1];
hpos=[0 1 1 0.15];
pos_colorbar=[0.95 0 0.05 1];

if nansum(isfield(axes_panel_comp,{'haxes','vaxes'}))==2
    %     hpos=get(axes_panel_comp.haxes,'Position');
    %     vpos=get(axes_panel_comp.vaxes,'Position');
else
    return;
end

switch state_colorbar
    case 'on'
        if isfield(axes_panel_comp,'colorbar')
           set(axes_panel_comp.colorbar,'visible','on');
           hpos=hpos+[0 0 -pos_colorbar(3) 0];
           pos=pos+[0 0 -pos_colorbar(3) 0];
        end
        
    case 'off'
        if isfield(axes_panel_comp,'colorbar')
            set(axes_panel_comp.colorbar,'visible','off');
        end
end


switch state_haxes
    case 'off'
        %set(axes_panel_comp.haxes,'visible','off');
        set(allchild(axes_panel_comp.haxes),'visible', 'off');
    case 'on'
        %set(axes_panel_comp.haxes,'visible','on');
        set(allchild(axes_panel_comp.haxes), 'visible', 'on');
        hpos=hpos+[0 -hpos(4) 0 0];
        vpos=vpos+[0 0 0 -hpos(4)];
        pos=pos+[0 0 0 -hpos(4)];
        pos_colorbar=pos_colorbar+[0 0 0 -hpos(4)];
end

switch state_vaxes
    case 'off'
        %set(axes_panel_comp.vaxes,'visible','off');
        set(allchild(axes_panel_comp.vaxes), 'visible', 'off')
    case 'on'
        %set(axes_panel_comp.vaxes,'visible','on');
        set(allchild(axes_panel_comp.vaxes), 'visible', 'on');
        vpos=vpos+[vpos(3) 0 0 0];
        hpos=hpos+[vpos(3) 0 -vpos(3) 0];
        pos=pos+[vpos(3) 0 -vpos(3) 0];
               
end

width_colorbar=pos_colorbar(3);
pos_colorbar(3)=width_colorbar*1/3;
pos_colorbar(1)=pos_colorbar(1)+width_colorbar*1/3;
height_col=pos_colorbar(4);
pos_colorbar(2)=height_col*0.05;
pos_colorbar(4)=height_col*0.9;
set(axes_panel_comp.colorbar,'Position',pos_colorbar);


set(axes_panel_comp.main_axes,'Position',pos);
set(axes_panel_comp.vaxes,'Position',vpos);
set(axes_panel_comp.haxes,'Position',hpos);
end