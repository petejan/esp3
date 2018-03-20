function listenDispBadTrans(src,listdata,main_figure)
main_menu=getappdata(main_figure,'main_menu');
set(main_menu.disp_bad_trans,'checked',listdata.AffectedObject.DispBadTrans);
%set_alpha_map(main_figure);
%update_mini_ax(main_figure,0);
switch listdata.AffectedObject.DispBadTrans
    case 'off'
        main_figure.Alphamap(3)=0;
    case 'on'
        main_figure.Alphamap(3)=0.6;
end

end