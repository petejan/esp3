function load_reglist_tab(main_figure,tab_panel)

switch tab_panel.Type
    case 'uitabgroup'
        reglist_tab_comp.reglist_tab=uitab(tab_panel,'Title','Region List');
        tab_menu = uicontextmenu(ancestor(tab_panel,'figure'));
        reglist_tab_comp.reglist_tab.UIContextMenu=tab_menu;
        uimenu(tab_menu,'Label','Undock Region List','Callback',{@undock_reglist_tab_callback,main_figure,'out_figure'});
    case 'figure'
        reglist_tab_comp.reglist_tab=tab_panel;
end




columnname = {'Name','ID','Tag','Type','Reference','Cell Width','Width Unit','Cell Height','Height Unit','Unique ID'};
columnformat = {'char' 'numeric','char',{'Data','Bad Data'},{'Surface','Bottom'},'numeric',{'pings','meters'},'numeric',{'meters','samples'},'numeric'};


reglist_tab_comp.table = uitable('Parent', reglist_tab_comp.reglist_tab,...
    'Data', [],...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'ColumnEditable', [false true true true true true true true true false],...
    'Units','Normalized','Position',[0 0 1 1],...
    'RowName',[]);

set(reglist_tab_comp.table,'CellEditCallback',{@edit_reg,main_figure});
set(reglist_tab_comp.table,'CellSelectionCallback',{@act_reg,main_figure});
set(reglist_tab_comp.reglist_tab,'SizeChangedFcn',@resize_table);
set(reglist_tab_comp.table,'KeyPressFcn',{@keypresstable,main_figure});
pos_t = getpixelposition(reglist_tab_comp.table);

set(reglist_tab_comp.table,'ColumnWidth',...
    num2cell(pos_t(3)*[5/20 1/20 2/20 2/20 2/20 2/20 2/20 2/20 2/20 0]));

setappdata(main_figure,'Reglist_tab',reglist_tab_comp);
setappdata(reglist_tab_comp.table,'SelectedRegs',[]);

update_reglist_tab(main_figure,[],1);
end


function keypresstable(src,evt,main_figure)
switch evt.Key
    case 'delete'
        layer=getappdata(main_figure,'Layer');
        curr_disp=getappdata(main_figure,'Curr_disp');
        idx_freq=find_freq_idx(layer,curr_disp.Freq);
        trans_obj=layer.Transceivers(idx_freq);
        idx=getappdata(src,'SelectedRegs');
        if ~isempty(idx)
            for i=1:numel(idx)
                trans_obj.rm_region_id(idx(i));
            end
            update_reglist_tab(main_figure,[],0);
            update_regions_tab(main_figure,nanmax(idx(end)-1,1));
            display_regions(main_figure,'both');
        end
end

end

function act_reg(src,evt,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);
regions=trans_obj.Regions;

if isempty(evt.Indices)
    setappdata(src,'SelectedRegs',[]);
    return;
else
    selected_regs=[src.Data{evt.Indices(:,1),end}];
    setappdata(src,'SelectedRegs',selected_regs);
end
[idx_reg,found]=trans_obj.find_reg_idx(src.Data{evt.Indices(end,1),10});

if ~found
    return;
end
active_reg=regions(idx_reg);
activate_region_callback([],[],active_reg,main_figure);
end



function resize_table(src,~)
table=findobj(src,'Type','uitable');

if~isempty(table)
    column_width=table.ColumnWidth;
    pos_f=getpixelposition(src);
    width_t_old=nansum([column_width{:}]);
    width_t_new=pos_f(3);
    new_width=cellfun(@(x) x/width_t_old*width_t_new,column_width,'un',0);
    set(table,'ColumnWidth',new_width);
end

end
