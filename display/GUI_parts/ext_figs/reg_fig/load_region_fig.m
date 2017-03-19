function load_region_fig(main_figure,reload,reg_uniqueID)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');
hfigs=getappdata(main_figure,'ExternalFigures');
hfigs(~isvalid(hfigs))=[];
idx_tag=find(strcmpi({hfigs(:).Tag},'regions_list'));
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);


if ~isempty(idx_tag)
    if reload==0
        figure(hfigs(idx_tag(1)))
        return;
    else
        reg_fig=hfigs(idx_tag(1));
        reg_table=getappdata(reg_fig,'reg_table');
    end
else
    
    if reload==0
        size_max = get(0, 'MonitorPositions');
        reg_fig=new_echo_figure(main_figure,...
            'Units','pixels',...
            'Position',[size_max(1,1)+size_max(1,3)/4 size_max(1,2)+1/5*size_max(1,4) size_max(1,3)/2 3*size_max(1,4)/5],...
            'Resize','on',...
            'MenuBar','none',...
            'Name','','Tag','regions_list');
            
    else
        return;
    end
end
set(reg_fig,'Name',sprintf('Regions for %.0fkHz',curr_disp.Freq/1e3));
regions=trans_obj.Regions;
if reload==0
    
    regDataSummary=update_data_table(regions,[]);
    
    columnname = {'Name','ID','Tag','Type','Reference','Cell Width','Width Unit','Cell Height','Height Unit','Unique ID'};
    columnformat = {'char' 'numeric','char',{'Data','Bad Data'},{'Surface','Bottom'},'numeric',{'pings','meters'},'numeric',{'meters','samples'},'numeric'};
    
    
    reg_table.table_main = uitable('Parent',reg_fig,...
        'Data', regDataSummary,...
        'ColumnName', columnname,...
        'ColumnFormat', columnformat,...
        'ColumnEditable', [false true true true true true true true true false],...
        'Units','Normalized','Position',[0 0 1 1],...
        'RowName',[]);
    
    set(reg_table.table_main,'CellEditCallback',{@edit_reg,reg_fig,main_figure});
    set(reg_table.table_main,'CellSelectionCallback',{@act_reg,reg_fig,main_figure});
    set(reg_fig,'SizeChangedFcn',@resize_table);
    pos_t = getpixelposition(reg_table.table_main);
    
    set(reg_table.table_main,'ColumnWidth',...
        num2cell(pos_t(3)*[5/20 1/20 2/20 2/20 2/20 1/20 2/20 1/20 2/20 2/20]));
    
    setappdata(reg_fig,'reg_table',reg_table);
    
else
    if ~isempty(reg_uniqueID)
        if reg_uniqueID>=0
            region_mod=regions(trans_obj.list_regions_Unique_ID(reg_uniqueID));
            reg_table_data=update_data_table(region_mod,reg_table.table_main.Data);
            set(reg_table.table_main,'Data',reg_table_data);
        else
            idx_mod=find(reg_table.table_main.Data{:,10}==abs(reg_uniqueID));
            if ~isempty(idx_mod)
                reg_table.table_main.Data(idx_mod,:)=[];
            end
        end
    else
        region_mod=regions;
        reg_table_data=update_data_table(region_mod,[]);   
        set(reg_table.table_main,'Data',reg_table_data);
    end
    
end

end

function act_reg(src,evt,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);
regions=trans_obj.Regions;

[idx_reg,found]=trans_obj.find_reg_idx(src.Data{evt.Indices(1),10});
if ~found
    return;
end
active_reg=regions(idx_reg);
activate_region_callback([],[],active_reg,main_figure);
end

function reg_table_data_new=update_data_table(regions,reg_table_data)

nb_regions=length(regions);
reg_table_data_new=cell(nb_regions,10);

for i=1:length(regions)
    if~isempty(reg_table_data)
        idx_mod=find(reg_table_data{:,10}==regions(i).Unique_ID);
    else
        idx_mod=[];
    end
    
    if ~isempty(idx_mod)
        reg_table_data(idx_mod,:)=[];
    end
    
    reg_table_data_new{i,1}=regions(i).Name;
    reg_table_data_new{i,2}=regions(i).ID;
    reg_table_data_new{i,3}=regions(i).Tag;
    reg_table_data_new{i,4}=regions(i).Type;
    reg_table_data_new{i,5}=regions(i).Reference;
    reg_table_data_new{i,6}=regions(i).Cell_w;
    reg_table_data_new{i,7}=regions(i).Cell_w_unit;
    reg_table_data_new{i,8}=regions(i).Cell_h;
    reg_table_data_new{i,9}=regions(i).Cell_h_unit;
    reg_table_data_new{i,10}=regions(i).Unique_ID;
end

reg_table_data_new=[reg_table_data;reg_table_data_new];

[~,idx_sort]=sort([reg_table_data_new{:,10}]);
reg_table_data_new=reg_table_data_new(idx_sort,:);
end


function edit_reg(src,evt,~,main_figure)
if isempty(evt.Indices)
    return;
end

 %columnname = {'Name','ID','Tag','Type','Reference','Cell Width','Width Unit','Cell Height','Height Unit','Unique ID'};
   
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);
regions=trans_obj.Regions;
[idx_reg,found]=trans_obj.find_reg_idx(src.Data{evt.Indices(1),10});

if ~found
    return;
end
active_reg=regions(idx_reg);
id=src.Data{evt.Indices(1),2};

if isnan(id)||id<=0
    id=active_reg.ID;
end
active_reg.ID=id;
active_reg.Tag=src.Data{evt.Indices(1),3};
active_reg.Type=src.Data{evt.Indices(1),4};
active_reg.Reference=src.Data{evt.Indices(1),5};
active_reg.Cell_w=src.Data{evt.Indices(1),6};
active_reg.Cell_w_unit=src.Data{evt.Indices(1),7};
active_reg.Cell_h=src.Data{evt.Indices(1),8};
active_reg.Cell_h_unit=src.Data{evt.Indices(1),9};
layer.Transceivers(idx_freq).add_region(active_reg);

setappdata(main_figure,'Layer',layer);
update_regions_tab(main_figure,[]);
display_regions(main_figure,'both');
order_stacks_fig(main_figure);

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
