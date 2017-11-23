function listenUnderBotTransparency(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
set_alpha_map(main_figure,'main_or_mini',union({'main','mini'},layer.ChannelID));
update_mini_ax(main_figure,0);

end