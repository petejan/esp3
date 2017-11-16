function update_multi_freq_disp_tab(main_figure)
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
%curr_disp=getappdata(main_figure,'Curr_disp');
multi_freq_disp_tab_comp=getappdata(main_figure,'multi_freq_disp_tab');

fLim=layer.get_flim();
set(multi_freq_disp_tab_comp.ax,'XLim',fLim/1e3+[-10 +10]);
set(multi_freq_disp_tab_comp.ax,'XTick',layer.Frequencies/1e3);
lines=findobj(multi_freq_disp_tab_comp.ax,'Type','line');

if ~isempty(layer.Curves)
    set(multi_freq_disp_tab_comp.ax,'visible','on');
    if ~isempty(lines)
        idx_rem=~ismember({lines(:).Tag},{layer.Curves(:).Unique_ID});
        idx_rem=idx_rem|strcmp({lines(:).Tag},'1');
        delete(lines(idx_rem))
        lines(idx_rem)=[];
    end
else
    delete(lines);
    set(multi_freq_disp_tab_comp.ax,'visible','off');
end


if isempty(layer.Curves)
    multi_freq_disp_tab_comp.table.Data={};
    idx_new=[];
    set(multi_freq_disp_tab_comp.table,'Data',multi_freq_disp_tab_comp.table.Data);
else
    curves=layer.get_curves_per_type('Sv(f)');
    if ~isempty(multi_freq_disp_tab_comp.table.Data)
        idx_rem=~ismember(multi_freq_disp_tab_comp.table.Data(:,4),{curves(:).Unique_ID})|strcmp(multi_freq_disp_tab_comp.table.Data(:,4),'1');
        multi_freq_disp_tab_comp.table.Data(idx_rem,:)=[];
        idx_new=find(~ismember({curves(:).Unique_ID},multi_freq_disp_tab_comp.table.Data(:,4)));
    else
        idx_new=1:numel(curves);
    end
     
end


for ic=idx_new
    id_c=findobj(multi_freq_disp_tab_comp.ax,'Tag',layer.Curves(ic).Unique_ID);
    if isempty(id_c)
        id_c=plot(multi_freq_disp_tab_comp.ax,layer.Curves(ic).XData,layer.Curves(ic).YData,'Tag',layer.Curves(ic).Unique_ID);
    end
    color_str=sprintf('rgb(%.0f,%.0f,%.0f)',floor(get(id_c,'Color')*255));
    u=size(multi_freq_disp_tab_comp.table.Data,1)+1;
    multi_freq_disp_tab_comp.table.Data{u,1}=strcat('<html><FONT color="',color_str,'">',curves(u).Name,'</html>');
    multi_freq_disp_tab_comp.table.Data{u,2}=curves(u).Tag;
    multi_freq_disp_tab_comp.table.Data{u,3}=true;
    multi_freq_disp_tab_comp.table.Data{u,4}=curves(u).Unique_ID;
end

end
