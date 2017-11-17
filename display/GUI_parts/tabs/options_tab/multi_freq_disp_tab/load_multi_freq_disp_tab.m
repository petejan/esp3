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
columnname = {'Name' 'Tag' 'Disp' 'ID'};
columnformat = {'char' 'char','logical','char'};


multi_freq_disp_tab_comp.table = uitable('Parent', multi_freq_disp_tab_comp.multi_freq_disp_tab,...
    'Data', {},...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'CellSelectionCallback',{@active_curve_cback,main_figure,tab_tag},...
    'CellEditCallback',{@edit_cell_cback,main_figure,tab_tag},...
    'ColumnEditable', [false false true false],...
    'Units','Normalized','Position',[2/3 0 1/3 1],...
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


multi_freq_disp_tab_comp.ax=axes('Parent',multi_freq_disp_tab_comp.multi_freq_disp_tab,'Units','normalized','box','on',...
     'OuterPosition',[0 0 2/3 1],'visible','off','NextPlot','add','box','on');
 multi_freq_disp_tab_comp.ax.XAxis.TickLabelFormat='%.0fkHz';
 multi_freq_disp_tab_comp.ax.XAxis.TickLabelRotation=0;
 multi_freq_disp_tab_comp.ax.YAxis.TickLabelFormat='%.0fdB';


grid(multi_freq_disp_tab_comp.ax,'on'); 
setappdata(main_figure,tab_tag,multi_freq_disp_tab_comp);

update_multi_freq_disp_tab(main_figure,tab_tag);

end

function add_curves_from_regions_cback(~,~,main_figure,tab_name)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
[trans_obj,~]=layer.get_trans(curr_disp);

switch tab_name
    case 'sv_f'
        for i=1:length(trans_obj.Regions)
            Sv_freq_response_func(main_figure,trans_obj.Regions(i)) ;
        end       
    case 'ts_f'        
        for i=1:length(trans_obj.Regions)
            TS_freq_response_func(main_figure,trans_obj.Regions(i)) ;
        end
        
end

end

function add_ts_curves_from_tracks_cback(~,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
[trans_obj,~]=layer.get_trans(curr_disp);
tracks = trans_obj.Tracks;
if~isempty(layer.Curves)
    layer.Curves(cellfun(@(x) ~isempty(strfind(x,'track')),{layer.Curves(:).Unique_ID}))=[];
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
    idx_pings=X_st(idx_targets);
    idx_r=Y_st(idx_targets);
    reg_obj=region_cl('Name','Tracks','Idx_r',idx_r,'Idx_pings',idx_pings,'ID',k,'Unique_ID',sprintf('track%.0f',k));
    TS_freq_response_func(main_figure,reg_obj) ;
end

end


function edit_cell_cback(src,evt,main_figure,tab_tag)
switch evt.Indices(2)
    case 3
        multi_freq_disp_tab_comp=getappdata(main_figure,tab_tag);
        data=multi_freq_disp_tab_comp.table.Data(evt.Indices(1),:);
        line_obj=findobj(multi_freq_disp_tab_comp.ax,{'Type','line','-and','Tag',data{4}});
        if ~isempty(line_obj)
            switch data{3}
                case true
                    set(line_obj,'Visible','on');
                case false
                    set(line_obj,'Visible','off');
            end
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
line_obj=findobj(multi_freq_disp_tab_comp.ax,{'Type','line','-and','Tag',data{4}});
other_lines_obj=findobj(multi_freq_disp_tab_comp.ax,{'Type','line','-and','-not','Tag',data{4}});

if ~isempty(other_lines_obj)
     set(other_lines_obj,'Linewidth',1);
end

if ~isempty(line_obj)
     set(line_obj,'Linewidth',2);
end

end