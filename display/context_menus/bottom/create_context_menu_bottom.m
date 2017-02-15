function create_context_menu_bottom(main_figure,bottom_line)

context_menu=uicontextmenu(main_figure);
bottom_line.UIContextMenu=context_menu;
uimenu(context_menu,'Label','Display Bottom Region','Callback',{@display_bottom_region_callback,main_figure});
uimenu(context_menu,'Label','Filter Bottom','Callback',{@filter_bottom_callback,main_figure});


end

function display_bottom_region_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

bot_range=trans_obj.get_bottom_range();
nb_pings=length(bot_range);
mean_depth=nanmean(trans_obj.get_bottom_range());

reg_wc=trans_obj.create_WC_region('y_min',mean_depth/50,...
    'y_max',0,...
    'Type','Data',...
    'Ref','Bottom',...
    'Cell_w',floor(nb_pings/100)+1,...
    'Cell_h',mean_depth/100,...
    'Cell_w_unit','pings',...
    'Cell_h_unit','meters');

reg_wc.display_region(trans_obj);



end

function filter_bottom_callback(~,~,main_figure)

prompt={'Filter Width (in pings)'};
defaultanswer={'10'};

answer=inputdlg(prompt,'Filter Width (in pings)',1,defaultanswer);

if isempty(answer)
    answer=defaultanswer;
end
if ~isnan(str2double(answer{1}))
    w_filter=str2double(answer{1});
else
    warning('Invalid filter_width');
    return
end
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

trans_obj.filter_bottom('FilterWidth',w_filter);

curr_disp.Bot_changed_flag=1;
setappdata(main_figure,'Curr_disp',curr_disp);
setappdata(main_figure,'Layer',layer);
display_bottom(main_figure);
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');

end