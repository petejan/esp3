
function set_alpha_map(main_figure,varargin)

p = inputParser;

addRequired(p,'main_figure',@ishandle);
addParameter(p,'main_or_mini','main');

parse(p,main_figure,varargin{:});

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');
switch p.Results.main_or_mini
    case 'main'
        axes_panel_comp=getappdata(main_figure,'Axes_panel');
        echo_im=axes_panel_comp.main_echo;
        echo_ax=axes_panel_comp.main_axes;
        echo_im_bt=axes_panel_comp.bad_transmits;
        set(axes_panel_comp.bottom_plot,'vis',curr_disp.DispUnderBottom);
    case 'mini'
        mini_axes_comp=getappdata(main_figure,'Mini_axes');
        echo_im=mini_axes_comp.mini_echo;
        echo_ax=mini_axes_comp.mini_ax;
        echo_im_bt=mini_axes_comp.mini_echo_bt;
end



[idx_freq,found]=find_freq_idx(layer,curr_disp.Freq);

if found==0
    curr_disp.Freq=layer.Frequencies(idx_freq);
end

min_axis=curr_disp.Cax(1);

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


if strcmp(curr_disp.DispBadTrans,'on')
    alpha_map(:,idx_bad_red)=1;
end
data_temp=nan(size(alpha_map));
data_temp(:,idx_bad_red)=Inf;


if ~isempty(layer.Transceivers(idx_freq).Bottom.Range)
    
    bot_vec_red=imresize(layer.Transceivers(idx_freq).Bottom.Range(idx_pings),[1,size(alpha_map,2)],'nearest');
    ydata_red=imresize(ydata,[size(alpha_map,1),1],'nearest');
    idx_bot_red=bsxfun(@le,bot_vec_red,ydata_red);
    
    
    if strcmpi(curr_disp.DispUnderBottom,'off')==1
        alpha_map(idx_bot_red)=0;
    end
    
end
if strcmp(curr_disp.DispBadTrans,'on')
    alpha_map_bt=(~isnan(data_temp))-0.2;
else
    alpha_map_bt=zeros(size(data_temp));
end

set(echo_im_bt,'XData',xdata,'YData',ydata,'CData',data_temp,'AlphaData',alpha_map_bt);
set(echo_ax,'CLim',curr_disp.Cax);
set(echo_im,'AlphaData',double(alpha_map));

if strcmpi(curr_disp.CursorMode,'Normal')&&strcmp(p.Results.main_or_mini,'main')
    create_context_menu_main_echo(main_figure);
end

order_stack(echo_ax);
order_axes(main_figure);
end