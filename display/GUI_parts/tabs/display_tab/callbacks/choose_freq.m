function  choose_freq(src,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
curr_disp.ChannelID=layer.ChannelID{get(src,'value')};
end