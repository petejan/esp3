
function activate_region_callback(obj,~,reg_curr,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

if ~strcmpi(curr_disp.CursorMode,'Normal')
    return;
end

switch curr_disp.Cmap
    
    case 'esp2'
        ac_data_col=[0 1 0];
        in_data_col=[1 0 0];
        txt_col='w';
    otherwise
        ac_data_col=[1 0 0];
        in_data_col=[0 1 0];
        txt_col='k';
end

idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

[idx_reg,found]=trans_obj.find_reg_idx(reg_curr.Unique_ID);

if found==0
    return;
end

axes_panel_comp=getappdata(main_figure,'Axes_panel');
mini_ax_comp=getappdata(main_figure,'Mini_axes');

ah=[axes_panel_comp.main_axes mini_ax_comp.mini_ax];


for i=1:length(ah)
    
    reg_text=findobj(ah(i),'Tag','region_text');
    set(reg_text,'color',txt_col);
    
    reg_lines_ac=findobj(ah(i),{'Tag','region','-or','Tag','region_cont'},'-and','UserData',reg_curr.Unique_ID,'-and','Type','line','-not','color',ac_data_col);
    reg_lines_in=findobj(ah(i),{'Tag','region','-or','Tag','region_cont'},'-not','UserData',reg_curr.Unique_ID,'-and','Type','line','-not','color',in_data_col);
    set(reg_lines_ac,'color',ac_data_col);
    set(reg_lines_in,'color',in_data_col);
    
    reg_image_ac=findobj(ah(i),{'Tag','region','-or','Tag','region_cont'},'-and','UserData',reg_curr.Unique_ID,'-and','Type','Image','-not','color',ac_data_col);
    if ~isempty(reg_image_ac)
        cdata=get(reg_image_ac,'CData');
        cdata(:,:,1)=ac_data_col(1);
        cdata(:,:,2)=ac_data_col(2);
        cdata(:,:,3)=ac_data_col(3);
        set(reg_image_ac,'Cdata',cdata);
    end
    
    reg_image_in=findobj(ah(i),{'Tag','region','-or','Tag','region_cont'},'-not','UserData',reg_curr.Unique_ID,'-and','Type','Image','-not','color',in_data_col);
    if ~isempty(reg_image_in)
        for i_inac=1:length(reg_image_in)
            cdata=get(reg_image_in(i_inac),'CData');
            cdata(:,:,1)=in_data_col(1);
            cdata(:,:,2)=in_data_col(2);
            cdata(:,:,3)=in_data_col(3);
            set(reg_image_in(i_inac),'Cdata',cdata);
        end
    end
    reg_patch_ac=findobj(ah(i),{'Tag','region','-or','Tag','region_cont'},'-and','UserData',reg_curr.Unique_ID,'-and','Type','Patch','-not','FaceColor',ac_data_col);
    set(reg_patch_ac,'FaceColor',ac_data_col,'EdgeColor',ac_data_col);
    
    reg_patch_in=findobj(ah(i),{'Tag','region','-or','Tag','region_cont'},'-not','UserData',reg_curr.Unique_ID,'-and','Type','Patch','-not','FaceColor',in_data_col);
    set(reg_patch_in,'FaceColor',in_data_col,'EdgeColor',in_data_col);
    
end
setappdata(main_figure,'Layer',layer);
update_regions_tab(main_figure,idx_reg);
order_axes(main_figure);
order_stacks_fig(main_figure);

if ~(isa(obj,'patch')||isa(obj,'image')) 
    return;
end

switch main_figure.SelectionType
    case 'normal'
        modifier = get(main_figure,'CurrentModifier');
        control = ismember({'alt'},modifier);
        
        if ~any(control)
            return;
        end

        switch obj.Type
            case 'patch'
                move_patch_select(obj,[],main_figure);
            case 'image'
                move_image_select(obj,[],main_figure);
        end
        
        waitfor(main_figure,'WindowButtonUpFcn','');
        
        r_min=nanmin(obj.YData);
        range=trans_obj.get_transceiver_range();
        [~,idx_r_min]=nanmin(abs(r_min-range));
        
        idx_p_min=ceil(nanmin(obj.XData));
        
        if reg_curr.Idx_r(1)==idx_p_min&&reg_curr.Idx_r(1)==idx_r_min
           return; 
        end
        
        reg_curr.Idx_pings=reg_curr.Idx_pings-reg_curr.Idx_pings(1)+idx_p_min;
        reg_curr.Idx_r=reg_curr.Idx_r-reg_curr.Idx_r(1)+idx_r_min;
        
        layer.Transceivers(idx_freq).add_region(reg_curr);
        
        setappdata(main_figure,'Layer',layer);
        
        update_regions_tab(main_figure,length(layer.Transceivers(idx_freq).Regions));
        order_axes(main_figure);
        display_regions(main_figure,'both');
        order_stacks_fig(main_figure);
        
end








