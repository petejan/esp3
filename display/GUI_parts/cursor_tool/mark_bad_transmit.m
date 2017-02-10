function mark_bad_transmit(src,~,main_figure)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
ah=axes_panel_comp.main_axes;

if gca~=ah
    return;
end

clear_lines(ah);


[~,idx_ping_ori]=get_ori(layer,curr_disp,axes_panel_comp.main_echo);
xdata=double(get(axes_panel_comp.main_echo,'XData'));
ydata=double(get(axes_panel_comp.main_echo,'YData'));

idx_freq=find_freq_idx(layer,curr_disp.Freq);


if strcmp(src.SelectionType,'normal')
    set_val=0;
elseif  strcmp(src.SelectionType,'alt')
    set_val=1;
else
    set_val=0;
end

%clear_lines(ah)

switch lower(curr_disp.Cmap)
    case 'esp2'
        line_col='w';
    otherwise
        line_col='k';
        
end

% range=layer.Transceivers(idx_freq).get_transceiver_range();

cp = ah.CurrentPoint;
xinit = cp(1,1);
yinit= cp(1,2);

if xinit<xdata(1)||xinit>xdata(end)||yinit<ydata(1)||yinit>ydata(end)
    return
end


switch src.SelectionType
    case {'normal','alt'}
        src.WindowButtonMotionFcn = @wbmcb;   
        x_bad=[xinit xinit];
        src.WindowButtonMotionFcn = @wbmcb;
        src.WindowButtonUpFcn = @wbucb;
        hp=plot(ah,x_bad,[yinit yinit],'color',line_col,'linewidth',1,'marker','x');
    otherwise
        [~,idx_bad]=min(abs(xdata-xinit));
        layer.Transceivers(idx_freq).Bottom.Tag(idx_bad+idx_ping_ori-1)=0;
        end_bt_edit();
end
    function wbmcb(~,~)
        
        cp = ah.CurrentPoint;
        
        X = sort([xinit ,cp(1,1)]);
        Y=  [cp(1,2),cp(1,2)];
        
        x_min=nanmin(X);
        x_min=nanmax(xdata(1),x_min);
        
        x_max=nanmax(X);
        x_max=nanmin(xdata(end),x_max);
        
        x_bad=[x_min x_max];
        
        set(hp,'XData',x_bad,'YData',Y);
    end

    function wbucb(src,~)
        
        delete(hp);
        src.WindowButtonMotionFcn = '';
        src.WindowButtonUpFcn = '';
        src.Pointer = 'arrow';
        [~,idx_start]=min(abs(xdata-min(x_bad)));
        [~,idx_end]=min(abs(xdata-max(x_bad)));
        idx_f=(idx_start:idx_end)+idx_ping_ori-1;
        
        layer.Transceivers(idx_freq).Bottom.Tag(idx_f)=set_val;
        
        end_bt_edit()
        
    end

    function end_bt_edit()
        reset_disp_info(main_figure);
        setappdata(main_figure,'Layer',layer);
        set_alpha_map(main_figure);
        update_mini_ax(main_figure,0);
    end

end
