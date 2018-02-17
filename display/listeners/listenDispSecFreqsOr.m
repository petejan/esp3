function listenDispSecFreqsOr(~,~,main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end
if isappdata(main_figure,'Secondary_freq')
    secondary_freq=getappdata(main_figure,'Secondary_freq');
    nb_chan=numel(secondary_freq.axes);
    
    for i=1:nb_chan
        switch curr_disp.DispSecFreqsOr
            case 'vert'
                pos=[(i-1)/nb_chan 0 1/nb_chan 1];
            case 'horz'
                pos=[0 1-i/nb_chan 1 1/nb_chan];
        end
        set(secondary_freq.axes(i),'Position',pos);
        
    end
    update_secondary_freq_win(main_figure);
end
end