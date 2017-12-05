
function set_alpha_map(main_figure,varargin)
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');
p = inputParser;

%profile on;
addRequired(p,'main_figure',@ishandle);
addParameter(p,'main_or_mini',union({'main','mini'},curr_disp.ChannelID));
addParameter(p,'update_bt',1);

parse(p,main_figure,varargin{:});


curr_disp=getappdata(main_figure,'Curr_disp');
update_bt=p.Results.update_bt;

if~iscell(p.Results.main_or_mini)
    main_or_mini={p.Results.main_or_mini};
else
   main_or_mini=p.Results.main_or_mini;
end

[echo_im_tot,echo_ax_tot,echo_im_bt_tot,trans_obj,~,~]=get_axis_from_cids(main_figure,main_or_mini);
if isempty(echo_im_tot)
    return;
end
[~,idx_pings]=get_idx_r_n_pings(layer,curr_disp,echo_im_tot(1));
min_axis=curr_disp.Cax(1);
for iax=1:length(echo_ax_tot)
    
    echo_im=echo_im_tot(iax);
    echo_ax=echo_ax_tot(iax);
    echo_im_bt=echo_im_bt_tot(iax);
    
    
    data=double(get(echo_im,'CData'));
    xdata=double(get(echo_im,'XData'));
    ydata=double(get(echo_im,'YData'));
    alpha_map=ones(size(data),'single');
    
    nb_pings=length(xdata);
    
    [~,nb_pings_red]=size(alpha_map);

    idxBad=find(trans_obj{iax}.Bottom.Tag==0);
    
    if nb_pings_red~=nb_pings
        idx_bad_red=unique(floor(nb_pings_red/nb_pings*(intersect(idxBad,idx_pings)-idx_pings(1)+1)));
        idx_bad_red(idx_bad_red==0)=[];
    else
        idx_bad_red=(intersect(idxBad,idx_pings)-idx_pings(1)+1);
        idx_bad_red(idx_bad_red==0)=[];
    end
    
    if strcmp(curr_disp.DispBadTrans,'on')
        alpha_map(:,idx_bad_red)=1;
    end
    
    
    
    bot_vec=trans_obj{iax}.get_bottom_idx(idx_pings);
    n_bot=size(alpha_map,2);
    
    if round(length(bot_vec)/n_bot)==length(bot_vec)/n_bot
        bot_vec_red=bot_vec(1:length(bot_vec)/n_bot:end);
    else
        bot_vec_red=imresize(bot_vec,[1,size(alpha_map,2)],'nearest');
    end
    
    
    ydata_red=linspace(ydata(1),ydata(end),size(alpha_map,1))';
    idx_bot_red=bsxfun(@le,bot_vec_red,ydata_red);
    
    
    if strcmpi(curr_disp.DispUnderBottom,'off')==1
        alpha_map(idx_bot_red)=1-curr_disp.UnderBotTransparency/100;
    end
    
    if update_bt>0
        data_temp=nan(2,size(alpha_map,2));
        data_temp(:,idx_bad_red)=Inf;
        
        if strcmp(curr_disp.DispBadTrans,'on')
            alpha_map_bt=(~isnan(data_temp))-0.6;
        else
            alpha_map_bt=zeros(2,size(data_temp,2));
        end
        
        set(echo_im_bt,'XData',xdata,'YData',[ydata(1) ydata(end)],'CData',data_temp,'AlphaData',alpha_map_bt);
    end
    
    alpha_map(data<min_axis|isnan(data))=0;
    
    set(echo_ax,'CLim',curr_disp.Cax);
    set(echo_im,'AlphaData',alpha_map);
    
    % if strcmpi(curr_disp.CursorMode,'Normal')&&strcmp(p.Results.main_or_mini,'main')
    %     create_context_menu_main_echo(main_figure);
    % end
    %display_info_ButtonMotionFcn([],[],main_figure,1);
    %order_axes(main_figure);
    % profile off;
    % profile viewer;
end
end