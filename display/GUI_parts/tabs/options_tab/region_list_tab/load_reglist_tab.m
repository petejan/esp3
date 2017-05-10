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


rc_menu = uicontextmenu(ancestor(tab_panel,'figure'));
reglist_tab_comp.table.UIContextMenu =rc_menu;str_delete='<HTML><center><FONT color="REd"><b>Delete region(s)</b></Font> ';
uimenu(rc_menu,'Label','Display region(s)','Callback',{@display_regions_callback,reglist_tab_comp.table,main_figure});
uimenu(rc_menu,'Label',str_delete,'Callback',{@delete_regions_callback,reglist_tab_comp.table,main_figure});

setappdata(main_figure,'Reglist_tab',reglist_tab_comp);
setappdata(reglist_tab_comp.table,'SelectedRegs',[]);

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
        reg_curr.display_region(trans_obj,'main_figure',main_figure);
  
    end
end
end

function delete_regions_callback(src,~,table,main_figure)
        layer=getappdata(main_figure,'Layer');
        curr_disp=getappdata(main_figure,'Curr_disp');
        idx_freq=find_freq_idx(layer,curr_disp.Freq);
        trans_obj=layer.Transceivers(idx_freq);
        idx=getappdata(table,'SelectedRegs');
        
        if ~isempty(idx)
            idx_reg=trans_obj.find_regions_Unique_ID(idx(end));
            for i=1:numel(idx)
                trans_obj.rm_region_id(idx(i));
            end
            update_reglist_tab(main_figure,[],0);
            update_regions_tab(main_figure,nanmax(idx_reg-1,1));            
            display_regions(main_figure,'both');
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

if ~found
    return;
end
active_reg=regions(idx_reg);
activate_region_callback([],[],active_reg.Unique_ID,main_figure,1);
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
