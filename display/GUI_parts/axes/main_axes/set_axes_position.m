function set_axes_position(main_figure)
main_menu=getappdata(main_figure,'main_menu');
axes_panel_comp=getappdata(main_figure,'Axes_panel');

state_colorbar=get(main_menu.show_colorbar,'checked');

curr_disp=getappdata(main_figure,'Curr_disp');

vpos_r=curr_disp.V_axes_ratio;
hpos_r=curr_disp.H_axes_ratio;

pos=[0 0 1 1];
vpos=[-vpos_r 0 vpos_r 1];
hpos=[0 1 1 hpos_r];
pos_colorbar=[1-0.05 0 0.05 1];

switch state_colorbar
    case 'on'
        set(axes_panel_comp.colorbar,'visible','on');
        hpos=hpos+[0 0 -pos_colorbar(3) 0];
        pos=pos+[0 0 -pos_colorbar(3) 0];
        
    case 'off'
        set(axes_panel_comp.colorbar,'visible','off');
end


hpos=hpos+[0 -hpos(4) 0 0];
vpos=vpos+[0 0 0 -hpos(4)];
pos=pos+[0 0 0 -hpos(4)];
pos_colorbar=pos_colorbar+[0 0 0 -hpos(4)];


vpos=vpos+[vpos(3) 0 0 0];
hpos=hpos+[vpos(3) 0 -vpos(3) 0];
pos=pos+[vpos(3) 0 -vpos(3) 0];



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