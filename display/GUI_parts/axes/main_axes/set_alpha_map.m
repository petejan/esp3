function set_alpha_map(main_figure,varargin)

p = inputParser;

addRequired(p,'main_figure',@ishandle);
addParameter(p,'echo_ax',[]);
addParameter(p,'echo_im',[]);

parse(p,main_figure,varargin{:});

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

if isempty(p.Results.echo_ax)||isempty(p.Results.echo_im)
    axes_panel_comp=getappdata(main_figure,'Axes_panel');
    
    if ~isfield(axes_panel_comp,'main_echo')
        return;
    end
    echo_im=axes_panel_comp.main_echo;
    echo_ax=axes_panel_comp.main_axes;
else
    echo_im=p.Results.echo_im;
    echo_ax=p.Results.echo_ax;
end

obj_del=findall(echo_ax,'tag','imtemp');
delete(obj_del);

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
        cmap='jet';
        echo_ax.Color='w';
    case 'hsv'
        cmap='hsv';
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
        axes(echo_ax);
        hold on;
        data_temp=nan(size(alpha_map));
        data_temp(:,idx_bad_red)=Inf;
        imtemp=imagesc(xdata,ydata,data_temp,'tag','imtemp');
        uistack(imtemp,'bottom');
        uistack(imtemp,'up');
        set(imtemp,'AlphaData',(~isnan(data_temp))-0.2);
        if strcmpi(curr_disp.CursorMode,'Normal')
            create_context_menu_main_echo(main_figure,imtemp);
        end
    end
    
end

colormap(echo_ax,cmap);
caxis(echo_ax,layer.Transceivers(idx_freq).Data.SubData(idx_field).CaxisDisplay);

if isa(echo_im,'matlab.graphics.primitive.Surface')
    set(echo_im,'AlphaData',double(alpha_map),'FaceAlpha','flat',...
        'AlphaDataMapping','scaled');
else
    set(echo_im,'AlphaData',double(alpha_map));
end



end