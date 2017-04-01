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
    ax_1= axes(hfig,'nextplot','add','OuterPosition',[0 0.66 1 0.33]);
    yyaxis(ax_1,'left');
    ax_1.YAxis(1).Color = 'r';
    plot(ax_1,roll_std,'r');
    ax_1.YAxis(1).TickLabelFormat  = '%g^\\circ';
    ylabel(ax_1,'Roll Std (^\\circ)');
    
      
    yyaxis(ax_1,'right');
    plot(ax_1,roll_grad_av,'k');
    ax_1.YAxis(2).Color = 'k';
    ax_1.YAxis(2).TickLabelFormat  = '%g^\\circ/s';
    legend(ax_1,'\Delta Roll','Roll rate change','Location','northeast')
    legend(ax_1,'boxoff')
    ylabel(ax_1,'Average Roll Change rate');
    grid(ax_1,'on');
    box(ax_1,'on');
    
    ax= axes(hfig,'nextplot','add','OuterPosition',[0 0.33 1 0.33]);
    yyaxis(ax,'left');
    ax.YAxis(1).Color = 'r';
    plot(ax,pitch_std,'r');
    ax.YAxis(1).TickLabelFormat  = '%g^\\circ';
    ylabel(ax,'Pitch Std (deg)');
    
    
    
    yyaxis(ax,'right');
    plot(ax,pitch_grad_av,'color','k');
    ax.YAxis(2).Color = 'k';
    ax.YAxis(2).TickLabelFormat  = '%g^\\circ/s';
    legend(ax,'\Delta Pitch','Pitch rate change','Location','northeast')
    legend(ax,'boxoff')
    ylabel(ax,'Average Pitch Change rate');
    grid(ax,'on');
    box(ax,'on');
    
    
    ax_2=axes(hfig,'nextplot','add','OuterPosition',[0 0 1 0.33]);
    plot(ax_2,bad_ping_pc,'b');
   
    ax_2.YAxis(1).Color = 'k';
    ax_2.YAxis(1).TickLabelFormat  = '%.0f ';
    ylabel(ax_2,'Bad Ping Percentage');
    grid(ax_2,'on');
    box(ax_2,'on');
    linkaxes([ax ax_1 ax_2],'x')
    
    P_roll = polyfit(bad_ping_pc,roll_grad_av,1);
    x_bad=nanmin(bad_ping_pc):nanmax(bad_ping_pc);
    hfig_2=new_echo_figure(main_figure,'Tag','rollbadanalysis','Name','Roll change rate against Bad Pings');
    ax_3= axes(hfig_2,'nextplot','add','OuterPosition',[0 0 1 1]);
    plot(ax_3,bad_ping_pc,roll_grad_av,'.b');
     plot(ax_3,x_bad,polyval(P_roll,x_bad));
    xlabel(ax_3,'Bad Ping Percentage');
    ylabel(ax_3,'Average Roll Change rate');
    title(ax_3,sprintf('Corr (Pearson): %.2f',corr(bad_ping_pc',roll_grad_av')));
    grid(ax_3,'on');
    box(ax_3,'on');
    
    
    P_pitch = polyfit(bad_ping_pc,pitch_grad_av,1);
    hfig_3=new_echo_figure(main_figure,'Tag','pitchbadanalysis','Name','Pitch change rate against Bad Pings');
    ax_4= axes(hfig_3,'nextplot','add','OuterPosition',[0 0 1 1]);
    plot(ax_4,bad_ping_pc,pitch_grad_av,'.b');
    plot(ax_4,x_bad,polyval(P_pitch,x_bad));
    title(ax_4,sprintf('Corr (Pearson): %.2f',corr(bad_ping_pc',pitch_grad_av')));
    xlabel(ax_4,'Bad Ping Percentage');
    ylabel(ax_4,'Average Pitch Change rate');
    grid(ax_4,'on');
    box(ax_4,'on');
    
    setappdata(main_figure,'Layers',layers);
    setappdata(main_figure,'Layer',layer);
 

end

