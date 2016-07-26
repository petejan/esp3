function mark_bad_transmit_single(src,evt,main_figure)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
ah=axes_panel_comp.main_axes;

[~,idx_pings]=get_idx_r_n_pings(layer,curr_disp,axes_panel_comp.main_echo);

xdata=double(get(axes_panel_comp.main_echo,'XData'));

idx_freq=find_freq_idx(layer,curr_disp.Freq);


if strcmp(src.SelectionType,'normal')
    set_val=0;
elseif  strcmp(src.SelectionType,'alt')
    set_val=1;
else
    return;
end

%clear_lines(ah)

switch lower(curr_disp.Cmap)
    case 'esp2'
        line_col='w';
    otherwise
        line_col='k';
        
end

% range=layer.Transceivers(idx_freq).Data.get_range();

cp = ah.CurrentPoint;
xinit = cp(1,1);
yinit=cp(1,2);

% if xinit<xdata(1)||xinit>xdata(end)||yinit<1||yinit>range(end)
%     return
% end

x_bad=[xinit xinit];

src.WindowButtonMotionFcn = @wbmcb;
src.WindowButtonUpFcn = @wbucb;

hp=plot(ah,x_bad,[yinit yinit],'color',line_col,'linewidth',1,'marker','x');

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
      

        src.WindowButtonMotionFcn = '';
        src.WindowButtonUpFcn = '';
        src.Pointer = 'arrow';
        [~,idx_start]=min(abs(xdata-min(x_bad)));
        [~,idx_end]=min(abs(xdata-max(x_bad)));
        idx_f=idx_pings(idx_start:idx_end);
        layer.Transceivers(idx_freq).Bottom.Tag(idx_f)=set_val;
        reset_disp_info(main_figure);
        setappdata(main_figure,'Layer',layer);
        set_alpha_map(main_figure);
        update_mini_ax(main_figure);
        delete(hp);

    end
end
