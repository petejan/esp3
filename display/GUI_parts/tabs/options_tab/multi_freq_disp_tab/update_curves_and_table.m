function update_curves_and_table(main_figure,tab_tag,id_new)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

switch tab_tag
    case 'sv_f'
        tab_name='Sv(f)';
    case 'ts_f'
        tab_name='TS(f)';
end

if ~iscell(id_new)
    id_new={id_new};
end

multi_freq_disp_tab_comp=getappdata(main_figure,tab_tag);

curves=layer.get_curves_per_type(tab_name);
average=ones(1,numel(id_new));

for i=1:numel(id_new)
    
    id_c=findobj(multi_freq_disp_tab_comp.ax,'Tag',id_new{i});
    
    idx=find(strcmp(id_new{i},{curves(:).Unique_ID})&strcmp({layer.Curves(:).Type},tab_tag));
    
    if isempty(idx)
        continue;
    end
    
    if multi_freq_disp_tab_comp.detrend_cbox.Value>0
        average(i)=nanmean(db2pow_perso(curves(idx).YData));
    end
    if multi_freq_disp_tab_comp.show_sd_bar.Value>0
        sd=curves(idx).SD;
    else
        sd=[];
    end
    if ~isempty(id_c)        
        set(id_c,'XData',curves(idx).XData,'YData',curves(idx).YData-pow2db_perso(average(i)),'YNegativeDelta',sd,'YPositiveDelta',sd,'Tag',curves(idx).Unique_ID);
        u=find(strcmp(id_new{i},multi_freq_disp_tab_comp.table.Data(:,4)));
        multi_freq_disp_tab_comp.table.Data{u,2}=curves(idx).Tag;
    else
        id_c=errorbar(multi_freq_disp_tab_comp.ax,curves(idx).XData,curves(idx).YData-pow2db_perso(average(i)),sd,...
            'Tag',curves(idx).Unique_ID,'ButtonDownFcn',{@display_line_cback,main_figure,tab_tag});
        
        color_str=sprintf('rgb(%.0f,%.0f,%.0f)',floor(get(id_c,'Color')*255));
        if ~isempty(multi_freq_disp_tab_comp.table.Data)
            u=find(strcmp(id_new{i},multi_freq_disp_tab_comp.table.Data(:,4)));
        else
            u=[];
        end
        if isempty(u)
            u=size(multi_freq_disp_tab_comp.table.Data,1)+1;
        end
        
        multi_freq_disp_tab_comp.table.Data{u,1}=strcat('<html><FONT color="',color_str,'">',curves(idx).Name,'</html>');
        multi_freq_disp_tab_comp.table.Data{u,2}=curves(idx).Tag;
        multi_freq_disp_tab_comp.table.Data{u,3}=true;
        multi_freq_disp_tab_comp.table.Data{u,4}=curves(idx).Unique_ID;
    end
    
end
end

function display_line_cback(src,evt,main_figure,tab_tag)
multi_freq_disp_tab_comp=getappdata(main_figure,tab_tag);
layer=getappdata(main_figure,'Layer');
cp=multi_freq_disp_tab_comp.ax.CurrentPoint;
x1 = cp(1,1);
y1 = cp(1,2);

idx_data=strcmp(src.Tag,multi_freq_disp_tab_comp.table.Data(:,4));
idx_c=strcmp(src.Tag,{layer.Curves(:).Unique_ID});
if any(idx_data)&&any(idx_c)
    text_obj=findobj(multi_freq_disp_tab_comp.ax,'Tag','DataText');
    if ~isempty(text_obj)
        set(text_obj,'Position',[x1,y1,0],'String',layer.Curves(idx_c).Name,'Color',src.Color);
    else
        text(multi_freq_disp_tab_comp.ax,x1,y1,layer.Curves(idx_c).Name,'Tag','DataText','Color',src.Color)
    end
end

end

