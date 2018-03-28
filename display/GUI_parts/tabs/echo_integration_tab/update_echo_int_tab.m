function update_echo_int_tab(main_figure,new)

if ~isappdata(main_figure,'EchoInt_tab')
    echo_tab_panel=getappdata(main_figure,'echo_tab_panel');
    load_echo_int_tab(main_figure,echo_tab_panel);
    return;
end

echo_int_tab_comp=getappdata(main_figure,'EchoInt_tab');
layer_obj=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

[~,idx_freq]=layer_obj.get_trans(curr_disp);
freqs=layer_obj.Frequencies;

if isempty(layer_obj.GPSData.Lat)
    units_w= {'pings','seconds'};
    xaxis_opt={'Ping Number' 'Time'};
else
    units_w= {'meters','pings','seconds'};
    xaxis_opt={'Distance' 'Ping Number' 'Time' 'Lat' 'Long'};
end

set(echo_int_tab_comp.cell_w_unit,'String',units_w);
if echo_int_tab_comp.cell_w_unit.Value>numel(units_w)
    echo_int_tab_comp.cell_w_unit.Value=1;
end
set(echo_int_tab_comp.tog_xaxis,'String',xaxis_opt);
if echo_int_tab_comp.tog_xaxis.Value>numel(xaxis_opt)
    echo_int_tab_comp.tog_xaxis.Value=1;
end

if new>0
    layer_obj.EchoIntStruct=layer_obj.EchoIntStruct;
    set(echo_int_tab_comp.tog_freq,'String',num2str(freqs'/1e3,'%.0f kHz'),'Value',idx_freq);
    reset_plot(echo_int_tab_comp);
    if ~isempty(layer_obj.EchoIntStruct)
        freqs_out=layer_obj.Frequencies(layer_obj.EchoIntStruct.idx_freq_out);
        idx_main=find(layer_obj.Frequencies(idx_freq)==freqs_out);
        set(echo_int_tab_comp.tog_tfreq,'String',num2str(freqs_out'/1e3,'%.0f kHz'),'Value',idx_main);
    else
        set(echo_int_tab_comp.tog_tfreq,'String','--');
    end
end

if ~isempty(layer_obj.EchoIntStruct)
    idx_main=echo_int_tab_comp.tog_tfreq.Value;
    echo_int_tab_comp=getappdata(main_figure,'EchoInt_tab');
else
    idx_main=[];
end

if isempty(layer_obj.EchoIntStruct)
    setappdata(main_figure,'EchoInt_tab',echo_int_tab_comp);
    return;
end

ref=echo_int_tab_comp.tog_ref.String{echo_int_tab_comp.tog_ref.Value};

if ~isempty(idx_main)
    out=[];
    switch lower(ref)
        case 'surface'
            if isempty(layer_obj.EchoIntStruct.output_2D_surf_tot{idx_main})
                reset_plot(echo_int_tab_comp);
                return;
            end
            out=layer_obj.EchoIntStruct.output_2D_surf_tot{idx_main};
        case 'bottom'
            if isempty(layer_obj.EchoIntStruct.output_2D_bot_tot{idx_main})
                reset_plot(echo_int_tab_comp);
                return;
            end
            out=layer_obj.EchoIntStruct.output_2D_bot_tot{idx_main};
    end
    %{'Ping Number' 'Distance' 'Time' 'Lat' 'Long'}
    x_disp_t=echo_int_tab_comp.tog_xaxis.String{echo_int_tab_comp.tog_xaxis.Value};
    switch x_disp_t
        case 'Ping Number'
            x_disp=out.Ping_S;
        case 'Distance'
            x_disp=out.Dist_S;
        case  'Time'
            x_disp=out.Time_S;
        case 'Lat'
            x_disp=out.Lat_S;
        case 'Long'
            x_disp=out.Lon_S;
    end
    if  ~any(~isnan(x_disp))
        x_disp=out.Ping_S;
        x_disp_t='Ping Number';
    end
    
    x_ticks=unique(nanmean(x_disp,1)); 
    nb_x=numel(x_ticks);
    dx=ceil(nb_x/40);
    
    if dx>1
        x_ticks=x_ticks(1:dx:end);
    end
    
    if (strcmpi(x_disp_t,'Distance')&&strcmpi(layer_obj.EchoIntStruct.params.Cell_w_unit,'meters'))||...
            (strcmpi(x_disp_t,'Ping Number')&&strcmpi(layer_obj.EchoIntStruct.params.Cell_w_unit,'pings'))...
            ||(strcmpi(x_disp_t,'Time')&&strcmpi(layer_obj.EchoIntStruct.params.Cell_w_unit,'seconds'))
        xl=num2cell(floor(x_ticks/layer_obj.EchoIntStruct.params.Cell_w)*layer_obj.EchoIntStruct.params.Cell_w);
    else
        xl=num2cell(x_ticks);
    end
    
    switch x_disp_t
        case 'Ping Number'
            x_labels=cellfun(@(x) sprintf('%d',x),xl,'UniformOutput',0);
        case 'Distance'
            x_labels=cellfun(@(x) sprintf('%.0fm',x),xl,'UniformOutput',0);
        case  'Time'
            h_fmt='HH:MM:SS';
            x_labels=cellfun(@(x) datestr(x,h_fmt),xl,'UniformOutput',0);
        case 'Lat'
            [x_labels,~]=cellfun(@(x) print_pos_str(x,zeros(size(x))),xl,'UniformOutput',0);
        case 'Long'
            [~,x_labels]=cellfun(@(x) print_pos_str(zeros(size(x)),x),xl,'UniformOutput',0);
    end
    

    
    switch lower(ref)
        case 'surface'
            y_disp=out.Layer_depth_min;
        case 'bottom'
            y_disp=out.Range_ref_min;
    end
    
    y_ticks=unique(nanmean(y_disp,2));
    y_ticks(isnan(y_ticks))=[];
    nb_y=numel(y_ticks);
    dy=ceil(nb_y/20);
    
    if dx>1
        y_ticks=y_ticks(1:dy:end);
    end
    
    if layer_obj.EchoIntStruct.params.Cell_w>1
        yl=num2cell(floor(abs(y_ticks)/layer_obj.EchoIntStruct.params.Cell_h)*layer_obj.EchoIntStruct.params.Cell_h);
        y_labels=cellfun(@(x) sprintf('%.0fm',x),yl,'UniformOutput',0);
    else
        yl=num2cell(abs(y_ticks));
        y_labels=cellfun(@(x) sprintf('%.0fm',x),yl,'UniformOutput',0);
    end
    

    
    switch echo_int_tab_comp.tog_type.String{echo_int_tab_comp.tog_type.Value}
        case 'Sv'
            c_disp=pow2db_perso(out.Sv_mean_lin);
            v_disp=pow2db_perso(nanmean(out.Sv_mean_lin,2));
            h_disp=pow2db_perso(nanmean(out.Sv_mean_lin,1));
            ty='sv';
        case 'PRC'
            c_disp=(out.PRC)*100;
            v_disp=(nanmean(out.PRC,2))*100;
            h_disp=(nanmean(out.PRC,1))*100;
            ty='prc';
        case 'Std Sv'
            c_disp=(out.Sv_dB_std);
            v_disp=(nanmean(out.Sv_dB_std,2));
            h_disp=(nanmean(out.Sv_dB_std,1));
            ty='std_sv';
        case 'Nb Samples'
            c_disp=(out.nb_samples);
            v_disp=(nanmean(c_disp,2));
            h_disp=(nanmean(c_disp,1));
            ty='nb_samples';
    end
    xlim=[nanmin(x_disp(:)) nanmax(x_disp(:))];
    ylim=[nanmin(y_disp(:)) nanmax(y_disp(:))];
else
    out=[];
end

if ~isempty(out)
    set(echo_int_tab_comp.main_plot,'Xdata',x_disp,'YData',y_disp,'Zdata',c_disp,'Cdata',c_disp,'visible','on','alphadata',ones(size(c_disp)),'userdata',ty);
    set(echo_int_tab_comp.v_plot,'xdata',v_disp,'ydata',nanmean(y_disp,2));
    set(echo_int_tab_comp.h_plot,'ydata',h_disp,'xdata',nanmean(x_disp,1));
    set(echo_int_tab_comp.main_ax,'xlim',xlim,'ylim',ylim,'xtick',x_ticks,'ytick',y_ticks);
    set(echo_int_tab_comp.h_ax,'XTickLabel',x_labels);
    set(echo_int_tab_comp.v_ax,'YTickLabel',y_labels);
    update_echo_int_alphamap(main_figure);
    update_echo_int_cmap(main_figure);
else
    reset_plot(echo_int_tab_comp);
end

setappdata(main_figure,'EchoInt_tab',echo_int_tab_comp);
end

function reset_plot(echo_int_tab_comp)
set(echo_int_tab_comp.main_plot,'Xdata',[0 0;0 0],'YData',[0 0;0 0],'CData',[0 0;0 0],'Zdata',[0 0;0 0],'alphadata',ones(size([0 0;0 0])));
set(echo_int_tab_comp.h_plot,'Xdata',0,'YData',0);
set(echo_int_tab_comp.v_plot,'Xdata',0,'YData',0);
set(echo_int_tab_comp.h_ax,'XTickLabel',{});
set(echo_int_tab_comp.v_ax,'YTickLabel',{});
end