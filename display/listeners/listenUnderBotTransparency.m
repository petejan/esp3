function listenUnderBotTransparency(~,listdata,main_figure)

switch listdata.AffectedObject.DispUnderBottom
    case 'off'
        main_figure.Alphamap(2)=1-listdata.AffectedObject.UnderBotTransparency/100;
    case 'on'
        main_figure.Alphamap(2)=1;
end


end