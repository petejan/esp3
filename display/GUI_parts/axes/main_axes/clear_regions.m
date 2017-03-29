function clear_regions(main_figure,ids)

%profile on;
if ~isdeployed
    disp('Clear regions')
end

axes_panel_comp=getappdata(main_figure,'Axes_panel');

mini_ax_comp=getappdata(main_figure,'Mini_axes');

main_axes_tot=[mini_ax_comp.mini_ax axes_panel_comp.main_axes];

for iax=1:length(main_axes_tot)
    if isempty(ids)
            delete(findobj(main_axes_tot(iax),'tag','region','-or','tag','region_text','-or','tag','region_cont'));
    else
        for i=1:numel(ids)
            id_reg=findobj(main_axes_tot(iax),{'tag','region','-or','tag','region_text','-or','tag','region_cont'},'-and','UserData',ids(i));
            delete(id_reg)
        end
    end
    
end

end