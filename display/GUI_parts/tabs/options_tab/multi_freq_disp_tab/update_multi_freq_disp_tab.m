function update_multi_freq_disp_tab(main_figure,tab_tag,replot)

switch tab_tag
    case 'sv_f'
        tab_name='Sv(f)';
    case 'ts_f'
        tab_name='TS(f)';      
end


multi_freq_disp_tab_comp=getappdata(main_figure,tab_tag);
if isempty(multi_freq_disp_tab_comp)
    opt_panel=getappdata(main_figure,'option_tab_panel');
    load_multi_freq_disp_tab(main_figure,opt_panel,tab_tag);
    return;
end



multi_freq_disp_tab_comp.detrend=multi_freq_disp_tab_comp.detrend_cbox.Value;
setappdata(main_figure,tab_tag,multi_freq_disp_tab_comp);
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

fLim=layer.get_flim();
set(multi_freq_disp_tab_comp.ax,'XLim',fLim/1e3+[-10 +10]);
set(multi_freq_disp_tab_comp.ax,'XTick',layer.Frequencies/1e3);
lines=findobj(multi_freq_disp_tab_comp.ax,'Type','line');
reg_uid=layer.get_layer_reg_uid();


if ~isempty(layer.Curves)
    idx_rem_c=~ismember({layer.Curves(:).Unique_ID},union(reg_uid,{'1'}))&(cellfun(@(x) ~contains(x,'track'),{layer.Curves(:).Unique_ID}));
    layer.Curves(idx_rem_c)=[];
end

if ~isempty(layer.Curves) 
    if ~isempty(lines)&&replot==0
        idx_rem=~ismember({lines(:).Tag},{layer.Curves(:).Unique_ID})|...
            ~ismember({lines(:).Tag},reg_uid);
        idx_rem=idx_rem|strcmp({lines(:).Tag},'1');
    else
        idx_rem=1:numel(lines);
    end
else
    idx_rem=1:numel(lines); 
end
delete(lines(idx_rem));

lines(idx_rem)=[];
if isempty(lines)
    tag_lines={''};
else
    tag_lines=get(lines,'Tag');
end


if isempty(layer.Curves)
    multi_freq_disp_tab_comp.table.Data={};    
    set(multi_freq_disp_tab_comp.table,'Data',multi_freq_disp_tab_comp.table.Data);
    return;
else
    curves=layer.get_curves_per_type(tab_name);
    if ~isempty(multi_freq_disp_tab_comp.table.Data)
        idx_rem=~ismember(multi_freq_disp_tab_comp.table.Data(:,4),{curves(:).Unique_ID})|...
            ~ismember(multi_freq_disp_tab_comp.table.Data(:,4),tag_lines)|...
            ~ismember(multi_freq_disp_tab_comp.table.Data(:,4),reg_uid)|...
            strcmp(multi_freq_disp_tab_comp.table.Data(:,4),'1');
        
        multi_freq_disp_tab_comp.table.Data(idx_rem,:)=[];
        %idx_new=find(~ismember({curves(:).Unique_ID},multi_freq_disp_tab_comp.table.Data(:,4)));
    else
        multi_freq_disp_tab_comp.table.Data(:,:)=[];
        %idx_new=1:numel(curves);
    end 
    %id_new={curves(idx_new).Unique_ID};
    id_new={curves(:).Unique_ID};
end

update_curves_and_table(main_figure,tab_tag,id_new);

nb_lines=size(multi_freq_disp_tab_comp.table.Data,1);

for il=1:nb_lines
    line_obj=findobj(multi_freq_disp_tab_comp.ax,{'Type','line','-and','Tag',multi_freq_disp_tab_comp.table.Data{il,4}});
    if ~isempty(line_obj)
        switch multi_freq_disp_tab_comp.table.Data{il,3}
            case true
                set(line_obj,'Visible','on');
            case false
                set(line_obj,'Visible','off');
        end
    end
end

cax=get(multi_freq_disp_tab_comp.ax,'YLim');
set(multi_freq_disp_tab_comp.thr_up,'String',num2str(cax(2),'%.0f'));
set(multi_freq_disp_tab_comp.thr_down,'String',num2str(cax(1),'%.0f'));

end
