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
        reglist_tab_comp.reglist_tab=new_echo_tab(main_figure,tab_panel,'Title','Region List','UiContextMenuName','reglist');
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

pos_t = getpixelposition(reglist_tab_comp.table);

set(reglist_tab_comp.table,'ColumnWidth',...
    num2cell(pos_t(3)*[5/20 1/20 2/20 2/20 2/20 2/20 2/20 2/20 2/20 0]));

set(reglist_tab_comp.table,'CellEditCallback',{@edit_reg,main_figure});
set(reglist_tab_comp.table,'CellSelectionCallback',{@act_reg,main_figure});
set(reglist_tab_comp.reglist_tab,'SizeChangedFcn',@resize_table);
set(reglist_tab_comp.table,'KeyPressFcn',{@keypresstable,main_figure});


rc_menu = uicontextmenu(ancestor(tab_panel,'figure'));
reglist_tab_comp.table.UIContextMenu =rc_menu;str_delete='<HTML><center><FONT color="REd"><b>Delete region(s)</b></Font> ';


uimenu(rc_menu,'Label','Display region(s)','Callback',{@display_regions_callback,main_figure});
uimenu(rc_menu,'Label',str_delete,'Callback',{@delete_regions_callback,main_figure});
uifreq=uimenu(rc_menu,'Label','Copy to other channels');
uimenu(uifreq,'Label','all','Callback',{@copy_region_from_selected_cback,main_figure});


reglist_tab_comp.jScroll = findjobj(reglist_tab_comp.table, 'class','UIScrollPanel');

setappdata(main_figure,'Reglist_tab',reglist_tab_comp);

update_reglist_tab(main_figure);

end

function copy_region_from_selected_cback(~,~,main_figure)
    copy_region_callback([],[],main_figure,[]);
end


function display_regions_callback(src,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,~]=layer.get_trans(curr_disp);

idx=curr_disp.Active_reg_ID;
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

function delete_regions_callback(src,~,main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
idx=curr_disp.Active_reg_ID;
delete_regions_from_uid(main_figure,idx);

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
[trans_obj,~]=layer.get_trans(curr_disp);

if isempty(evt.Indices)
    selected_regs=[];
else
    selected_regs=src.Data(evt.Indices(:,1),end);
end

active_regs=trans_obj.get_region_from_Unique_ID(selected_regs);
if ~isempty(active_regs)    
    if ~all(ismember({active_regs(:).Unique_ID},curr_disp.Active_reg_ID))||isempty(setdiff({active_regs(:).Unique_ID},curr_disp.Active_reg_ID))
        curr_disp.setActive_reg_ID({active_regs(:).Unique_ID});
        set_view_to_region(active_regs(1).Unique_ID,main_figure);
    end
else
   curr_disp.setActive_reg_ID({}); 
end
end
