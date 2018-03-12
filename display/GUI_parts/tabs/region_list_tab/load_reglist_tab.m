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

gui_fmt=init_gui_fmt_struct();
gui_fmt.txt_w=80;
pos=create_pos_3(7,2,gui_fmt.x_sep,gui_fmt.y_sep,gui_fmt.txt_w,gui_fmt.box_w,gui_fmt.box_h);

p_button=pos{6,1}{1};
p_button(3)=gui_fmt.button_w;

reg_curr=region_cl();

uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.txtStyle,'String','Tag','Position',pos{1,1}{1});
reglist_tab_comp.tag=uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.edtStyle,'String',reg_curr.Tag,'Position',pos{1,1}{2}+[0 0 gui_fmt.box_w 0]);

data_type={'Data' 'Bad Data'};
data_idx=find(strcmp(data_type,reg_curr.Type));
uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.txtStyle,'String','Data Type','Position',pos{2,1}{1});
reglist_tab_comp.data_type=uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.popumenuStyle,'String',data_type,'Value',data_idx,'Position',pos{2,1}{2}+[0 0 gui_fmt.box_w 0]);

%ref={'Surface','Bottom','Line'};

ref={'Surface','Bottom','Line'};
ref_idx=find(strcmp(reg_curr.Reference,ref));
uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.txtStyle,'String','Reference','Position',pos{3,1}{1});
reglist_tab_comp.tog_ref=uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.popumenuStyle,'String',ref,'Value',ref_idx,'Position',pos{3,1}{2}+[0 0 gui_fmt.box_w 0]);


uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.txtStyle,'String','Cell Width','Position',pos{4,1}{1});
reglist_tab_comp.cell_w=uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.edtStyle,'position',pos{4,1}{2},'string',reg_curr.Cell_w,'Tag','w');

uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.txtStyle,'String','Cell Height','Position',pos{5,1}{1});
reglist_tab_comp.cell_h=uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.edtStyle,'position',pos{5,1}{2},'string',reg_curr.Cell_h,'Tag','h');
set([reglist_tab_comp.cell_w reglist_tab_comp.cell_h],'callback',{@check_cell,main_figure})

units_w= {'pings','meters'};
units_h={'meters','samples'};

h_unit_idx=find(strcmp(reg_curr.Cell_h_unit,units_h));
w_unit_idx=find(strcmp(reg_curr.Cell_w_unit,units_w));

reglist_tab_comp.cell_w_unit=uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.popumenuStyle,'String',units_w,'Value',w_unit_idx,'Position',pos{4,2}{1},'Tag','w');
reglist_tab_comp.cell_h_unit=uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.popumenuStyle,'String',units_h,'Value',h_unit_idx,'Position',pos{5,2}{1},'Tag','h');
reglist_tab_comp.cell_w_unit_curr=get(reglist_tab_comp.cell_w_unit,'value');
reglist_tab_comp.cell_h_unit_curr=get(reglist_tab_comp.cell_w_unit,'value');
set(reglist_tab_comp.cell_w_unit ,'callback',{@tog_units,main_figure});
set(reglist_tab_comp.cell_h_unit ,'callback',{@tog_units,main_figure});



str_delete='<HTML><center><FONT color="Red"><b>Delete</b></Font> ';
str_delete_all='<HTML><center><FONT color="Red"><b>Del. All</b></Font> ';

uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.pushbtnStyle,'String',str_delete,'pos',p_button,'callback',{@delete_region_callback,main_figure,[]});
uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.pushbtnStyle,'String',str_delete_all,'pos',p_button+[gui_fmt.button_w 0 0 0],'callback',{@delete_all_region_callback,main_figure});
% uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.pushbtnStyle,'String','Del. Across Freq.','TooltipString','Delete Across Frequencies','pos',[0.65 0.1 0.15 0.15],'callback',{@rm_over_freq_callback,main_figure});
% uicontrol(reglist_tab_comp.reglist_tab,gui_fmt.pushbtnStyle,'String','Copy Across Freq.','TooltipString','Copy All Regions Across Frequencies','pos',[0.5 0.1 0.15 0.15],'callback',{@copy_to_other_freq,main_figure});
% 

columnname = {'Name','ID','Tag','Type','Reference','Cell Width','Width Unit','Cell Height','Height Unit','Unique ID'};
columnformat = {'char' 'numeric','char',{'Data','Bad Data'},{'Surface','Bottom'},'numeric',{'pings','meters'},'numeric',{'meters','samples'},'numeric'};


reglist_tab_comp.table = uitable('Parent', reglist_tab_comp.reglist_tab,...
    'Data', [],...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'ColumnEditable', [false true true true true true true true true false],...
    'Units','Normalized','Position',[0.3 0 0.7 1],...
    'RowName',[]);


pos_t = getpixelposition(reglist_tab_comp.table);

set(reglist_tab_comp.table,'ColumnWidth',...
    num2cell(pos_t(3)*[4/20 1/20 2/20 2/20 3/20 2/20 2/20 2/20 2/20 0]));

set(reglist_tab_comp.table,'CellEditCallback',{@edit_reg,main_figure});
set(reglist_tab_comp.table,'CellSelectionCallback',{@act_reg,main_figure});
set(reglist_tab_comp.reglist_tab,'SizeChangedFcn',@resize_table);
set(reglist_tab_comp.table,'KeyPressFcn',{@keypresstable,main_figure});


rc_menu = uicontextmenu(ancestor(tab_panel,'figure'));
reglist_tab_comp.table.UIContextMenu =rc_menu;str_delete='<HTML><center><FONT color="REd"><b>Delete region(s)</b></Font> ';


uimenu(rc_menu,'Label','Display region(s)','Callback',{@display_regions_callback,main_figure});
uimenu(rc_menu,'Label','Export Region(s)','Callback',{@export_regions_callback,main_figure});
uimenu(rc_menu,'Label',str_delete,'Callback',{@delete_regions_callback,main_figure,[]});

% reglist_tab_comp.jScroll = findjobj(reglist_tab_comp.table, 'class','UIScrollPanel');
% 
% jscrollpane = findjobj(reglist_tab_comp.table);
% jtable = jscrollpane.getViewport.getView;
%  
% % Now turn the JIDE sorting on
% jtable.setSortable(true);		% or: set(jtable,'Sortable','on');
% jtable.setAutoResort(true);
% jtable.setMultiColumnSortable(true);
% jtable.setPreserveSelectionsAfterSorting(true);
% 
setappdata(main_figure,'Reglist_tab',reglist_tab_comp);

update_reglist_tab(main_figure,0);

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


function keypresstable(src,evt,main_figure)
switch evt.Key
    case 'delete'
        delete_regions_callback(src,[],main_figure,[]);
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
