
function activate_region_callback(~,~,reg_curr,main_figure)

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
ah=axes_panel_comp.main_axes;

reg_text=findobj(ah,'Tag','region_text');
set(reg_text,'color',txt_col);

reg_lines_ac=findobj(ah,{'Tag','region','-or','Tag','region_cont'},'-and','UserData',reg_curr.Unique_ID,'-and','Type','line','-not','color',ac_data_col);
reg_lines_in=findobj(ah,{'Tag','region','-or','Tag','region_cont'},'-not','UserData',reg_curr.Unique_ID,'-and','Type','line','-not','color',in_data_col);
set(reg_lines_ac,'color',ac_data_col);
set(reg_lines_in,'color',in_data_col);

reg_image_ac=findobj(ah,{'Tag','region','-or','Tag','region_cont'},'-and','UserData',reg_curr.Unique_ID,'-and','Type','Image','-not','color',ac_data_col);
        cdata=get(reg_image_ac,'CData');
        cdata(:,:,1)=ac_data_col(1);
        cdata(:,:,2)=ac_data_col(2);
        cdata(:,:,3)=ac_data_col(3);
set(reg_image_ac,'Cdata',cdata);

reg_image_in=findobj(ah,{'Tag','region','-or','Tag','region_cont'},'-not','UserData',reg_curr.Unique_ID,'-and','Type','Image','-not','color',in_data_col);

for i_inac=1:length(reg_image_in)
    cdata=get(reg_image_in(i_inac),'CData');
    cdata(:,:,1)=in_data_col(1);
    cdata(:,:,2)=in_data_col(2);
    cdata(:,:,3)=in_data_col(3);
    set(reg_image_in(i_inac),'Cdata',cdata);
end

setappdata(main_figure,'Layer',layer);
update_regions_tab(main_figure,idx_reg);
order_axes(main_figure);
order_stacks_fig(main_figure);




