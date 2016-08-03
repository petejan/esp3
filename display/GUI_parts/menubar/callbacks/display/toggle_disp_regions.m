function toggle_disp_regions(main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

%main_axes_tot=[axes_panel_comp.main_axes display_tab_comp.mini_ax];
main_axes_tot=axes_panel_comp.main_axes;
switch curr_disp.DispReg
    case 'on'
        alpha_in=0;
    case 'off'
        alpha_in=0;
end
for iax=1:length(main_axes_tot)
    main_axes=main_axes_tot(iax);
    u_reg_line=findobj(main_axes,'tag','region','-and','Type','line');
    set(u_reg_line,'visible',curr_disp.DispReg);
    
%     for i=1:length(u_reg)
%         switch class(u_reg(i))
%             case 'matlab.graphics.primitive.Patch'
%                 set(u_reg(i),'FaceAlpha',alpha_in);
%             case 'matlab.graphics.primitive.Image'
%                 cdata=get(u_reg(i),'CData');
%                 set(u_reg(i),'AlphaData',alpha_in*double(nansum(cdata,3)>0));
%            case 'matlab.graphics.primitive.Line'
%                set(u_reg(i),'visible',curr_disp.DispReg);
%         end
%     end
    order_stacks_fig(main_figure);
    
end

