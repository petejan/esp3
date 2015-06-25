function mark_bad_transmit(src,~,main_figure)


layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
ah=axes_panel_comp.main_axes;


xdata=double(get(axes_panel_comp.main_echo,'XData'));

idx_freq=find_freq_idx(layer,curr_disp.Freq);


if strcmp(src.SelectionType,'normal')
    set_val=1;
elseif  strcmp(src.SelectionType,'alt')
    set_val=0;
else
    return;
end

dat=layer.Transceivers(idx_freq).Data.SubData(1).DataMat;

range=layer.Transceivers(idx_freq).Data.Range;

[~,nb_pings]=size(dat);

cp = ah.CurrentPoint;
xinit = cp(1,1);
yinit=cp(1,2);

if xinit<xdata(1)||xinit>xdata(end)||yinit<1||yinit>range(end)
    return
end

x_box=xinit;

src.WindowButtonMotionFcn = @wbmcb;
src.WindowButtonUpFcn = @wbucb;

    function wbmcb(~,~)
        
        cp = ah.CurrentPoint;
        
        X = [xinit,cp(1,1)];

        
        x_min=nanmin(X);
        x_min=nanmax(xdata(1),x_min);
        
        x_max=nanmax(X);
        x_max=nanmin(xdata(end),x_max);
        
        x_box=[x_min x_max  x_max x_min x_min];
 
    end

    function wbucb(src,~)

        src.WindowButtonMotionFcn = '';
        src.WindowButtonUpFcn = '';
        src.Pointer = 'arrow';
        [~,idx_start]=nanmin(abs(xdata-nanmin(x_box)));
        [~,idx_end]=nanmin(abs(xdata-nanmax(x_box)));
        idx_pings=idx_start:idx_end;
        pings=zeros(1,nb_pings);
        if ~isempty(layer.Transceivers(idx_freq).IdxBad)
            pings(layer.Transceivers(idx_freq).IdxBad)=1;
        end
        pings(idx_pings)=set_val;
        layer.Transceivers(idx_freq).IdxBad=find(pings);
        reset_disp_info(main_figure);
        setappdata(main_figure,'Layer',layer);
        set_alpha_map(main_figure);
        
    end
end
