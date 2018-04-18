
function load_multi_freq_disp_tab(main_figure,tab_panel,tab_tag)

switch tab_tag
    case 'sv_f'
        tab_name='Sv(f)';
    case 'ts_f'
         tab_name='TS(f)';      
end

switch tab_panel.Type
    case 'uitabgroup'
        multi_freq_disp_tab_comp.multi_freq_disp_tab=new_echo_tab(main_figure,tab_panel,'Title',tab_name,'UiContextMenuName',tab_tag);
        
    case 'figure'
        multi_freq_disp_tab_comp.multi_freq_disp_tab=tab_panel;
end

gui_fmt=init_gui_fmt_struct();
gui_fmt.txt_w=gui_fmt.txt_w*1.4;

size_tab=getpixelposition(multi_freq_disp_tab_comp.multi_freq_disp_tab);

height=nanmin(size_tab(4)-20,80);
width=300;

size_opt=[10 size_tab(4)-height width-20 height];
ax_size=[size_opt(3)+size_opt(1) 0 size_tab(3)-size_opt(3) size_tab(4)];
table_size=[size_opt(1) 5 size_opt(3) size_tab(4)-size_opt(4)-5];


multi_freq_disp_tab_comp.ax=axes('Parent',multi_freq_disp_tab_comp.multi_freq_disp_tab,'Units','pixels','box','on',...
     'OuterPosition',ax_size,'visible','on','NextPlot','add','box','on');
 multi_freq_disp_tab_comp.ax.XAxis.TickLabelFormat='%.0f kHz';
 multi_freq_disp_tab_comp.ax.XAxis.TickLabelRotation=45;
 multi_freq_disp_tab_comp.ax.YAxis.TickLabelFormat='%.0fdB';
grid(multi_freq_disp_tab_comp.ax,'on'); 


multi_freq_disp_tab_comp.opt_panel=uibuttongroup(multi_freq_disp_tab_comp.multi_freq_disp_tab,'units','pixels','Position',size_opt,'Title','Options','background','white');


pos=create_pos_3(5,2,gui_fmt.x_sep,gui_fmt.y_sep,gui_fmt.txt_w,gui_fmt.box_w,gui_fmt.box_h);

 multi_freq_disp_tab_comp.ax_lim_cbox=uicontrol(multi_freq_disp_tab_comp.opt_panel,gui_fmt.chckboxStyle,...
     'position',pos{5,1}{1},'String','Fix YLim.','Value',0,'Callback',{@fix_ylim,main_figure,tab_tag});
 
cax=get(multi_freq_disp_tab_comp.ax,'YLim'); 
multi_freq_disp_tab_comp.thr_down=uicontrol(multi_freq_disp_tab_comp.opt_panel,gui_fmt.edtStyle,'position',pos{5,1}{2},'string',cax(1));
multi_freq_disp_tab_comp.thr_up=uicontrol(multi_freq_disp_tab_comp.opt_panel,gui_fmt.edtStyle,'position',pos{5,1}{2}+[gui_fmt.box_w+gui_fmt.x_sep 0 0 0],'string',cax(2));
set([multi_freq_disp_tab_comp.ax_lim_cbox multi_freq_disp_tab_comp.thr_up multi_freq_disp_tab_comp.thr_down],'callback',{@fix_ylim,main_figure,tab_tag});

%  multi_freq_disp_tab_comp.ax_lim_cbox=uicontrol(multi_freq_disp_tab_comp.multi_freq_disp_tab,gui_fmt.chckboxStyle,...
%      'BackgroundColor','White','units','normalized','position',[0.25 0.9 0.25 0.1],'String','Link YLim to Echo.','Value',0,'Callback',{@link_ylim_to_echo_clim,main_figure,tab_tag});
%  
 multi_freq_disp_tab_comp.detrend_cbox=uicontrol(multi_freq_disp_tab_comp.opt_panel,gui_fmt.chckboxStyle,...
     'position',pos{4,1}{1},'String','Normalize Curves','Value',0,'Callback',{@detrend_curves_cback,main_figure,tab_tag});
 multi_freq_disp_tab_comp.show_sd_bar=uicontrol(multi_freq_disp_tab_comp.opt_panel,gui_fmt.chckboxStyle,...
     'position',pos{4,1}{1}+[gui_fmt.txt_w 0 0 0],'String','Show Error Bars','Value',0,'Callback',{@detrend_curves_cback,main_figure,tab_tag});

columnname = {'Name' 'Tag' 'Disp' 'ID'};
columnformat = {'char' 'char','logical','char'};


multi_freq_disp_tab_comp.table = uitable('Parent', multi_freq_disp_tab_comp.multi_freq_disp_tab,...
    'Data', {},...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'CellSelectionCallback',{@active_curve_cback,main_figure,tab_tag},...
    'CellEditCallback',{@edit_cell_cback,main_figure,tab_tag},...
    'ColumnEditable', [false true true false],...
    'Units','pixels','Position',table_size,...
    'RowName',[]);

pos_t = getpixelposition(multi_freq_disp_tab_comp.table);

set(multi_freq_disp_tab_comp.table,'ColumnWidth',...
    num2cell(pos_t(3)*[4/6 1/6 1/6 0]));

set(multi_freq_disp_tab_comp.multi_freq_disp_tab,'SizeChangedFcn',@resize_table);
rc_menu = uicontextmenu(ancestor(tab_panel,'figure'));
multi_freq_disp_tab_comp.table.UIContextMenu =rc_menu;

uimenu(rc_menu,'Label',['Produce ' tab_name ' curves from regions'],'Callback',{@add_curves_from_regions_cback,main_figure,tab_tag});
switch tab_tag
    case 'sv_f'
    case 'ts_f'
        uimenu(rc_menu,'Label',['Produce ' tab_name ' curves from tracks'],'Callback',{@add_ts_curves_from_tracks_cback,main_figure});
end
uimenu(rc_menu,'Label',['Clear ' tab_name ' curves'],'Callback',{@clear_curves_cback,main_figure,tab_tag});

select_menu=uimenu(rc_menu,'Label','Select');
uimenu(select_menu,'Label','All','Callback',{@selection_callback,main_figure,tab_tag},'Tag','se');
uimenu(select_menu,'Label','De-Select All','Callback',{@selection_callback,main_figure,tab_tag},'Tag','de');
uimenu(select_menu,'Label','Inverse Selection','Callback',{@selection_callback,main_figure,tab_tag},'Tag','inv');


% pos=getpixelposition(multi_freq_disp_tab_comp.multi_freq_disp_tab);
set(multi_freq_disp_tab_comp.multi_freq_disp_tab,'ResizeFcn',{@resize_mf_tab,main_figure,tab_tag})


setappdata(main_figure,tab_tag,multi_freq_disp_tab_comp);
create_context_menu_mf_plot(main_figure,tab_tag);
update_multi_freq_disp_tab(main_figure,tab_tag,0);

end

function resize_mf_tab(src,evt,main_figure,tab_tag)
multi_freq_disp_tab_comp=getappdata(main_figure,tab_tag);

size_tab=getpixelposition(multi_freq_disp_tab_comp.multi_freq_disp_tab);

height=nanmin(size_tab(4)-20,80);
width=300;

size_opt=[10 size_tab(4)-height width-20 height];
ax_size=[size_opt(3)+size_opt(1) 0 size_tab(3)-size_opt(3) size_tab(4)];
table_size=[size_opt(1) 5 size_opt(3) size_tab(4)-size_opt(4)-5];


set(multi_freq_disp_tab_comp.opt_panel,'Position',size_opt);
set(multi_freq_disp_tab_comp.ax,'OuterPosition',ax_size);
set(multi_freq_disp_tab_comp.table,'OuterPosition',table_size);

end

function detrend_curves_cback(src,evt,main_figure,tab_tag)
update_multi_freq_disp_tab(main_figure,tab_tag,0);
end


function selection_callback(src,~,main_figure,tab_tag)
multi_freq_disp_tab_comp=getappdata(main_figure,tab_tag);
data=multi_freq_disp_tab_comp.table.Data;
for i=1:size(data,1)
    switch src.Tag
        case 'se'
            data{i,end-1}=true;
        case 'de'
            data{i,end-1}=false;
        case 'inv'
            data{i,end-1}=~data{i,end-1};
    end
end
set(multi_freq_disp_tab_comp.table,'Data',data);

update_multi_freq_disp_tab(main_figure,tab_tag,0);

end


function clear_curves_cback(~,~,main_figure,tab_name)

layer=getappdata(main_figure,'Layer');
if isempty(layer.Curves)
    return;
end
switch tab_name
    case 'ts_f'
    layer.Curves(strcmp({layer.Curves(:).Type},'ts_f'))=[];    
    case 'sv_f'
    layer.Curves(strcmp({layer.Curves(:).Type},'sv_f'))=[];
end
update_multi_freq_disp_tab(main_figure,tab_name,1);
end

function add_curves_from_regions_cback(~,~,main_figure,tab_name)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
[trans_obj,~]=layer.get_trans(curr_disp);
idx=trans_obj.find_regions_type('Data');
regs=trans_obj.Regions(idx);
switch tab_name
    case 'sv_f'
        for i=1:length(regs)
            Sv_freq_response_func(main_figure,regs(i)) ;
        end     

    case 'ts_f'        
        for i=1:length(regs)
            TS_freq_response_func(main_figure,regs(i)) ;
        end
      
end
update_multi_freq_disp_tab(main_figure,tab_name,1);
end

function add_ts_curves_from_tracks_cback(~,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
[trans_obj,~]=layer.get_trans(curr_disp);
tracks = trans_obj.Tracks;
if~isempty(layer.Curves)
    layer.Curves(contains({layer.Curves(:).Unique_ID},'track'))=[];
end
if isempty(tracks)
    return;
end
ST = trans_obj.ST;
X_st=ST.Ping_number;
Y_st=ST.idx_r;
if isempty(tracks.target_id)
    return;
end

for k=1:length(tracks.target_id)
    idx_targets=tracks.target_id{k};
    idx_pings=sort(X_st(idx_targets));
    idx_r=sort(Y_st(idx_targets));    
    reg_obj=region_cl('Name','Tracks','Idx_r',idx_r,'Idx_pings',idx_pings,'ID',k,'Unique_ID',sprintf('track%.0f',k));
    TS_freq_response_func(main_figure,reg_obj) ;
end
update_multi_freq_disp_tab(main_figure,'ts_f',0);
end


function edit_cell_cback(~,evt,main_figure,tab_tag)
switch evt.Indices(2)
    case 3
        multi_freq_disp_tab_comp=getappdata(main_figure,tab_tag);
        data=multi_freq_disp_tab_comp.table.Data(evt.Indices(1),:);
        line_obj=findobj(multi_freq_disp_tab_comp.ax,{'Tag',data{4}});
        if ~isempty(line_obj)
            switch data{3}
                case true
                    set(line_obj,'Visible','on');
                case false
                    set(line_obj,'Visible','off');
            end
        end
    case 2
        multi_freq_disp_tab_comp=getappdata(main_figure,tab_tag);
        %curr_disp=getappdata(main_figure,'Curr_disp');
        data=multi_freq_disp_tab_comp.table.Data(evt.Indices(1),:);
        layer=getappdata(main_figure,'Layer');       
        idx_mod=layer.set_tag_to_region_with_uid(data{4},data{2});

        idx_c=find(strcmp(data{4},{layer.Curves(:).Unique_ID}));
        for it=1:numel(idx_c)
            layer.Curves(idx_c(it)).Tag=data{2};
        end
        update_reglist_tab(main_figure,0);
        display_regions(main_figure,union({'main' 'mini'},layer.ChannelID(idx_mod)));
        
        switch tab_tag
            case 'ts_f'
                update_curves_and_table(main_figure,'sv_f',{layer.Curves(:).Unique_ID});
            case 'sv_f'
                update_curves_and_table(main_figure,'ts_f',{layer.Curves(:).Unique_ID});
        end
    otherwise
end

end

function active_curve_cback(src,evt,main_figure,tab_tag)
if isempty(evt.Indices)
    return;
end

multi_freq_disp_tab_comp=getappdata(main_figure,tab_tag);
data=multi_freq_disp_tab_comp.table.Data(evt.Indices(end,1),:);
line_obj=findobj(multi_freq_disp_tab_comp.ax,{'Type','errorbar','-and','Tag',data{4}});
other_lines_obj=findobj(multi_freq_disp_tab_comp.ax,{'Type','errorbar','-and','-not','Tag',data{4}});

if ~isempty(other_lines_obj)
     set(other_lines_obj,'Linewidth',1);
end

if ~isempty(line_obj)
     set(line_obj,'Linewidth',2);
end

text_obj=findobj(multi_freq_disp_tab_comp.ax,'Tag','DataText');
if ~isempty(text_obj)
    delete(text_obj);
end
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