function display_st_or_track_hist(main_figure,ax,disp_var)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);

if isempty(ax)
    hfig=new_echo_figure(main_figure,'tag','track_histo');
    tt=sprintf('Track from %.0f kHz',curr_disp.Freq/1e3);
    ax=axes(hfig);
    title(ax,tt);
    grid(ax,'on');
    xlabel(ax,'TS(dB)');
    grid(ax,'on');
end

for i=1:length(disp_var)
    obj=findobj(ax,'Tag',disp_var{i});
    delete(obj);
end


set(ax,'YTickLabel','');
if isempty(trans_obj)
    return;
end
ST = trans_obj.ST;

alpha=[1 0.5];
legend_str=cell(1,length(disp_var));
if isempty(ST)
    return;
else
    for i=1:length(disp_var)
        TS=[];
        switch disp_var{i}
            case 'st'
                TS = ST.TS_comp;
                col='r';
                legend_str{i}='Single Targets';
            case 'tracks'
                tracks = trans_obj.Tracks;
                
                if isempty(tracks)
                    continue;
                end
                
                if isempty(tracks.target_id)
                    continue;
                end
                
                col='b';
                legend_str{i}='Tracked Targets';
                for k=1:length(tracks.target_id)
                    idx_targets=tracks.target_id{k};
                    TS=[TS ST.TS_comp(idx_targets)];
                end
        end
        if ~isempty(TS)
            [pdf_temp,x_temp]=pdf_perso(TS,'bin',25);
            bar(ax,x_temp,pdf_temp,'Tag',disp_var{i},'FaceColor',col,'FaceAlpha',alpha(i));
        else
            legend_str{i}=[];
        end
    end
    if ~all(cellfun(@isempty,legend_str))
        legend_str(cellfun(@isempty,legend_str))=[];
        legend(ax,legend_str);
    end
end





end