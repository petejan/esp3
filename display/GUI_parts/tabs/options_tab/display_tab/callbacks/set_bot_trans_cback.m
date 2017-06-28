function set_bot_trans_cback(~,~,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
curr_disp=getappdata(main_figure,'Curr_disp');

alpha=1-str2double(get(display_tab_comp.trans_bot,'String'))/100;
if alpha>1||alpha<0||isnan(alpha)
    set(display_tab_comp.trans_bot,'String',num2str(100-curr_disp.UnderBotTransparency*100,'%.0f'));
    return;
end

curr_disp.UnderBotTransparency=1-alpha;


end