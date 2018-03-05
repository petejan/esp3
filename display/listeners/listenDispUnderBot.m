function listenDispUnderBot(src,listdata,main_figure)
main_menu=getappdata(main_figure,'main_menu');
set(main_menu.disp_under_bot,'checked',listdata.AffectedObject.DispUnderBottom);
%layer=getappdata(main_figure,'Layer');
% set_alpha_map(main_figure,'main_or_mini',union({'main','mini'},layer.ChannelID));
% update_mini_ax(main_figure,0);

switch listdata.AffectedObject.DispUnderBottom
    case 'off'
        main_figure.Alphamap(2)=1-listdata.AffectedObject.UnderBotTransparency/100;
    case 'on'
        main_figure.Alphamap(2)=1;
end

end