function set_alpha_map(main_figure,varargin)

p = inputParser;

addRequired(p,'main_figure',@ishandle);
addParameter(p,'main_or_mini','main');

parse(p,main_figure,varargin{:});

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

switch p.Results.main_or_mini
    case 'main'
        axes_panel_comp=getappdata(main_figure,'Axes_panel');
        echo_im=axes_panel_comp.main_echo;
        echo_ax=axes_panel_comp.main_axes;
        echo_im_bt=axes_panel_comp.bad_transmits;
    case 'mini'
        display_tab_comp=getappdata(main_figure,'Display_tab');
        echo_im=display_tab_comp.mini_echo;
        echo_ax=display_tab_comp.mini_ax;
        echo_im_bt=display_tab_comp.mini_echo_bt;
end


curr_disp=getappdata(main_figure,'Curr_disp');
[idx_freq,found]=find_freq_idx(layer,curr_disp.Freq);

if found==0
    curr_disp.Freq=layer.Frequencies(idx_freq);
end
idx_field=find_field_idx(layer.Transceivers(idx_freq).Data,curr_disp.Fieldname);
min_axis=layer.Transceivers(idx_freq).Data.SubData(idx_field).CaxisDisplay(1);

data=double(get(echo_im,'CData'));
xdata=double(get(echo_im,'XData'));
ydata=double(get(echo_im,'YData'));
alpha_map=double(data>=min_axis);

nb_pings=length(xdata);

[~,nb_pings_red]=size(alpha_map);
[~,idx_pings]=get_idx_r_n_pings(layer,curr_disp,echo_im);

idxBad=find(layer.Transceivers(idx_freq).Bottom.Tag==0);
idx_bad_red=unique(floor(nb_pings_red/nb_pings*(intersect(idxBad,idx_pings)-idx_pings(1)+1)));
idx_bad_red(idx_bad_red==0)=[];

switch lower(curr_disp.Cmap)
    case 'jet'
        cmap=colormap('jet');
        echo_ax.Color='w';
    case 'hsv'
        cmap=colormap('hsv');
        echo_ax.Color='w';
    case 'esp2'
        cmap=esp2_colormap();
        echo_ax.Color='k';
    case 'ek500'
        cmap=ek500_colormap();
        echo_ax.Color='w';
end

if strcmp(curr_disp.DispBadTrans,'on')
    alpha_map(:,idx_bad_red)=1;
end


if ~isempty(layer.Transceivers(idx_freq).Bottom.Range)


        bot_vec_red=imresize(layer.Transceivers(idx_freq).Bottom.Range(idx_pings),[1,size(alpha_map,2)],'nearest'); 
        ydata_red=imresize(ydata,[size(alpha_map,1),1],'nearest'); 
        idx_bot_red=bsxfun(@le,bot_vec_red,ydata_red);  

        
    if strcmpi(curr_disp.DispUnderBottom,'off')==1
        curr_disp.DispBottom='off';
        alpha_map(idx_bot_red)=0;
    else
        curr_disp.DispBottom='on';
    end
    
    if strcmp(curr_disp.DispBadTrans,'on')
        data_temp=nan(size(alpha_map));
        data_temp(:,idx_bad_red)=Inf;
        set(echo_im_bt,'XData',xdata,'YData',ydata,'CData',data_temp,'AlphaData',(~isnan(data_temp))-0.2);
        if strcmpi(curr_disp.CursorMode,'Normal')
            create_context_menu_main_echo(main_figure,echo_im_bt);
        end
    end
    
end


colormap(echo_ax,cmap);

set(echo_ax,'CLim',layer.Transceivers(idx_freq).Data.SubData(idx_field).CaxisDisplay);

if isa(echo_im,'matlab.graphics.primitive.Surface')
    set(echo_im,'AlphaData',double(alpha_map),'FaceAlpha','flat',...
        'AlphaDataMapping','scaled');
else
    set(echo_im,'AlphaData',double(alpha_map));
end
order_stack(echo_ax);
order_axes(main_figure);
end