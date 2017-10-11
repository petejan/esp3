%% load_reglist_tab.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |main_figure|: TODO: write description and info on variable
% * |tab_panel|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * 2017-03-28: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function load_reglist_tab(main_figure,tab_panel)


switch tab_panel.Type
    case 'uitabgroup'
        reglist_tab_comp.reglist_tab=uitab(tab_panel,'Title','Region List');
        tab_menu=create_context_menu_tabs(main_figure,tab_panel,'reglist');  
        reglist_tab_comp.reglist_tab.UIContextMenu=tab_menu;
    case 'figure'
        reglist_tab_comp.reglist_tab=tab_panel;
end

columnname = {'Name','ID','Tag','Type','Reference','Cell Width','Width Unit','Cell Height','Height Unit','Unique ID'};
columnformat = {'char' 'numeric','char',{'Data','Bad Data'},{'Surface','Bottom','Line'},'numeric',{'pings','meters'},'numeric',{'meters','samples'},'numeric'};


reglist_tab_comp.table = uitable('Parent', reglist_tab_comp.reglist_tab,...
    'Data', [],...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'ColumnEditable', [false true true true true true true true true false],...
    'Units','Normalized','Position',[0 0 1 1],...
    'RowName',[]);

reglist_tab_comp.jScroll = findjobj(reglist_tab_comp.table, 'class','UIScrollPanel');
set(reglist_tab_comp.table,'CellEditCallback',{@edit_reg,main_figure});
set(reglist_tab_comp.table,'CellSelectionCallback',{@act_reg,main_figure});
set(reglist_tab_comp.reglist_tab,'SizeChangedFcn',@resize_table);
set(reglist_tab_comp.table,'KeyPressFcn',{@keypresstable,main_figure});
pos_t = getpixelposition(reglist_tab_comp.table);

set(reglist_tab_comp.table,'ColumnWidth',...
    num2cell(pos_t(3)*[5/20 1/20 2/20 2/20 2/20 2/20 2/20 2/20 2/20 0]));


rc_menu = uicontextmenu(ancestor(tab_panel,'figure'));
reglist_tab_comp.table.UIContextMenu =rc_menu;str_delete='<HTML><center><FONT color="REd"><b>Delete region(s)</b></Font> ';
uimenu(rc_menu,'Label','Display region(s)','Callback',{@display_regions_callback,reglist_tab_comp.table,main_figure});
uimenu(rc_menu,'Label',str_delete,'Callback',{@delete_regions_callback,reglist_tab_comp.table,main_figure});
reglist_tab_comp.jScroll = findjobj(reglist_tab_comp.table, 'class','UIScrollPanel');

setappdata(reglist_tab_comp.table,'SelectedRegs',[]);
setappdata(main_figure,'Reglist_tab',reglist_tab_comp);

update_reglist_tab(main_figure,[],1);

end


function display_regions_callback(src,~,table,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);
idx=getappdata(table,'SelectedRegs');
if ~isempty(idx)
    for i=1:numel(idx)
        [ireg,found]=trans_obj.find_reg_idx(idx(i));
        if found==0
            continue;
        end
        reg_curr=trans_obj.Regions(ireg);
        switch reg_curr.Reference
            case 'Line'
                line_obj=layer.get_first_line();
            otherwise
                line_obj=[];
        end

        reg_curr.display_region(trans_obj,'main_figure',main_figure,'line_obj',line_obj);
        
    end
end
end

function delete_regions_callback(src,~,table,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

 trans_obj=layer.get_trans(curr_disp.Freq);
idx=getappdata(table,'SelectedRegs');

if ~isempty(idx)
     old_regs=trans_obj.Regions;
     
    for i=1:numel(idx)
        trans_obj.rm_region_id(idx(i));
    end
    
    display_regions(main_figure,'both');

    add_undo_region_action(main_figure,trans_obj,old_regs,trans_obj.Regions);
    
    order_stacks_fig(main_figure);
    curr_disp.Active_reg_ID=trans_obj.get_reg_first_Unique_ID();
    
end
end



function keypresstable(src,evt,main_figure)
switch evt.Key
    case 'delete'
        delete_regions_callback(src,[],src,main_figure);
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
    selected_regs=unique([src.Data{evt.Indices(:,1),end}]);
    setappdata(src,'SelectedRegs',selected_regs);
end

[idx_reg,found]=trans_obj.find_reg_idx(src.Data{evt.Indices(end,1),10});

if evt.Indices(end)~=1
    return;
end

if ~found
    return;
end

fig=ancestor(src,'figure');
modifier = get(fig,'CurrentModifier');
control = ismember({'shift' 'control'},modifier);

if any(control)
    return;
end

active_reg=regions(idx_reg);

if active_reg.Unique_ID~=curr_disp.Active_reg_ID
    curr_disp.Active_reg_ID=active_reg.Unique_ID;
    set_view_to_region(curr_disp.Active_reg_ID,main_figure);
end

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
