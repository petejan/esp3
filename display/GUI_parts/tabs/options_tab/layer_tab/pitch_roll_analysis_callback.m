function pitch_roll_analysis_callback(src,~,table,main_figure)

 layers=getappdata(main_figure,'Layers');
    layer=getappdata(main_figure,'Layer');
    selected_layers=getappdata(table,'SelectedLayers');
    curr_disp=getappdata(main_figure,'Curr_disp');


   
    if isempty(layer)
        return;
    end
    
    if isempty(selected_layers)
        return;
    end
    pitch_av=nan(1,numel(selected_layers));
    pitch_std=nan(1,numel(selected_layers));
    pitch_grad_av=nan(1,numel(selected_layers));
    roll_av=nan(1,numel(selected_layers));
    roll_std=nan(1,numel(selected_layers));
    roll_grad_av=nan(1,numel(selected_layers));
    bad_ping_pc=nan(1,numel(selected_layers));

    for i=1:numel(selected_layers)

        [idx,~]=find_layer_idx(layers,selected_layers(i));
        

        layer_curr=layers(idx);
        idx_freq=find_freq_idx(layer_curr,curr_disp.Freq);
 
        bad_ping_pc(i)=layer_curr.Transceivers(idx_freq).get_badtrans_perc();
        
        [pitch_av(i),pitch_std(i),pitch_grad_av(i),roll_av(i),roll_std(i),roll_grad_av(i)]=layer_curr.produce_pitch_roll_analysis();
        
    end
    
    hfig=new_echo_figure(main_figure,'Tag','pitchrollanalysis','Name','Picth/Roll Analysis');
    ax= axes(hfig,'nextplot','add','OuterPosition',[0 0.5 1 0.5]);
    yyaxis(ax,'left');
    ax.YAxis(1).Color = 'r';
    plot(ax,roll_std,'r');
    plot(ax,pitch_std,'k');
    ax.YAxis(1).TickLabelFormat  = '%g^\\circ';
    ylabel(ax,'Motion Std (deg)');
    
    
    yyaxis(ax,'right');
    plot(ax,roll_grad_av,'b');
    plot(ax,pitch_grad_av,'color',[0 0.5 0]);
    ax.YAxis(2).Color = 'k';
    ax.YAxis(2).TickLabelFormat  = '%g^\\circ/s';
    legend(ax,'\Delta Roll','\Delta Pitch','Roll rate change','Ping rate change','Location','northeast')
    legend(ax,'boxoff')
    ylabel(ax,'Average Motion Change rate');
    grid(ax,'on');
    box(ax,'on');
    
    
    ax_2=axes(hfig,'nextplot','add','OuterPosition',[0 0 1 0.5]);
    plot(ax_2,bad_ping_pc,'b');
   
    ax_2.YAxis(1).Color = 'k';
    ax_2.YAxis(1).TickLabelFormat  = '%.0f ';
    ylabel(ax_2,'Bad Ping Percentage');
    grid(ax_2,'on');
    box(ax_2,'on');
    
    setappdata(main_figure,'Layers',layers);
    setappdata(main_figure,'Layer',layer);
 

end

