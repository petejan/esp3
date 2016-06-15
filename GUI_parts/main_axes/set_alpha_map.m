function set_alpha_map(hObject,varargin)

p = inputParser;

addRequired(p,'hObject',@ishandle);
addParameter(p,'echo_ax',[]);
addParameter(p,'echo_im',[]);

parse(p,hObject,varargin{:});

layer=getappdata(hObject,'Layer');
if isempty(layer)
    return;
end

if isempty(p.Results.echo_ax)||isempty(p.Results.echo_im)
    axes_panel_comp=getappdata(hObject,'Axes_panel');
    
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

curr_disp=getappdata(hObject,'Curr_disp');
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
nb_samples=length(ydata);

[~,nb_pings_red]=size(alpha_map);
[~,idx_pings]=get_idx_r_n_pings(layer,curr_disp,echo_im);

idxBad=find(layer.Transceivers(idx_freq).Bottom.Tag==0);
idx_bad_red=unique(floor(nb_pings_red/nb_pings*(intersect(idxBad,idx_pings)-idx_pings(1)+1)));
idx_bad_red(idx_bad_red==0)=[];

if strcmp(curr_disp.DispBadTrans,'on')
    alpha_map(:,idx_bad_red)=0.5;
end

switch curr_disp.Cmap
    case 'jet'
        cmap='jet';
    case 'hsv'
        cmap='hsv';
    case 'esp2'
        cmap=esp2_colormap();
        alpha_map(alpha_map==0)=1;
    case 'ek500'
        cmap=ek500_colormap();
        alpha_map(:,idx_bad_red)=0.5;
end

Range_mat=repmat(ydata,1,nb_pings);
if ~isempty(layer.Transceivers(idx_freq).Bottom.Range)
    bot_mat=repmat(layer.Transceivers(idx_freq).Bottom.Range(idx_pings),nb_samples,1);
    idx_bot=Range_mat>bot_mat;
    idx_bot_red=imresize(idx_bot,size(alpha_map));
    
    if strcmpi(curr_disp.DispUnderBottom,'off')==1
        if strcmp(curr_disp.Cmap,'esp2')
            axes(echo_ax);
            hold on;
            imtemp=imagesc(xdata,ydata,-999*ones(size(alpha_map)),'tag','imtemp');
            uistack(imtemp,'bottom');
            uistack(imtemp,'up');
            set(imtemp,'AlphaData',double(idx_bot_red));

        else
            alpha_map(idx_bot_red)=0;
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