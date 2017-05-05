
function [TS_f,f_vec]=freq_response_sp_mat_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);


active_reg=reg_curr;

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');

if strcmp(trans_obj.Mode,'FM')
    [cal_path,~,~]=fileparts(layer.Filename{1});
    file_cal=fullfile(cal_path,['Curve_' num2str(layer.Frequencies(idx_freq),'%.0f') '.mat']);
    
    
    if exist(file_cal,'file')>0
        disp('Calibration file loaded.');
        cal=load(file_cal);
    else
        disp('No calibration file');
        cal=[];
    end
    [cmap,~,~,col_grid,~,~]=init_cmap(curr_disp.Cmap);
    
    
    [TS_f,f_vec,pings,range]=trans_obj.TS_f_from_region(active_reg,'envdata',layer.EnvData,'cal',cal,'dp',1,'load_bar_comp',load_bar_comp);
    
    
    
    TS_f_per=permute(TS_f,[1 3 2]);
    
    
    f_val=floor(nanmean(f_vec));
    [~,idx_freq]=nanmin(abs(f_vec-f_val));
    f_val=f_vec(idx_freq);
    
    [X,Y,Z] = meshgrid(f_vec/1e3,pings,range);
    
    fig=new_echo_figure(main_figure,'Name','Sp(f)','Tag',sprintf('SpRegion2 %.0f',active_reg.Unique_ID));
    
    ax=axes(fig,'units','normalized','Position',[0.15 0.2 0.85 0.7]);
    set(ax,'zdir','reverse','ydir','reverse','box','on');
    grid(ax,'on');
    
    hold(ax,'on');
    %hz=surface(ax,squeeze(X(:,:,end)),squeeze(Y(:,:,end)),squeeze(Z(:,:,end)),squeeze(TS_f_per(:,:,end)));
    hy=surface(ax,squeeze(X(1,:,:)),squeeze(Y(1,:,:)),squeeze(Z(1,:,:)),squeeze(TS_f_per(1,:,:)));
    %hx0=surface(ax,squeeze(X(:,end,:)),squeeze(Y(:,end,:)),squeeze(Z(:,end,:)),squeeze(TS_f_per(:,end,:)));
    hx = surface(ax,squeeze(X(:,idx_freq,:)),squeeze(Y(:,idx_freq,:)),squeeze(Z(:,idx_freq,:)),squeeze(TS_f_per(:,idx_freq,:)));
    
    view(3);
    colormap(ax,cmap);
    caxis(ax,curr_disp.getCaxField('sp'));
    
    set([hx hy],'FaceAlpha', 'interp','FaceColor','interp','EdgeColor','none');
    set(hx,'alphadata',double(hx.CData>ax.CLim(1)));
    %         set(hx0,'alphadata',double(hx0.CData>ax.CLim(1)));
    set(hy,'alphadata',double(hy.CData>ax.CLim(1)));
    %set(hz,'alphadata',double(hz.CData>ax.CLim(1)));
    zlabel(ax,'Range(m)');
    ylabel(ax,sprintf('Ping Number %.0f',pings(1)));
    xlabel(ax,sprintf('%.1fkHz',f_val/1e3));
    set(ax,'Xlim',[f_vec(1)/1e3 f_vec(end)/1e3],'Ylim',[pings(1) pings(end)],'Zlim',[range(1) range(end)]);
    colorbar(ax);
    uicontrol(fig,'Style','slider','Min',f_vec(1)/1e3,'Max',f_vec(end)/1e3,'Value',f_val/1e3,'SliderStep',[0.01 0.1],...
        'units','normalized','Position',[0.2 0.05 0.6 0.02],'Callback',{@change_freq_cback_2,TS_f_per,f_vec,X,hx,ax,'f'});
    grid(ax,'on');
    uicontrol(fig,'Style','slider','Min',pings(1),'Max',pings(end),'Value',pings(end),'SliderStep',[0.01 0.1],...
        'units','normalized','Position',[0.05 0.1 0.01 0.4],'Callback',{@change_freq_cback_2,TS_f_per,pings,Y,hy,ax,'p'});
    grid(ax,'on');
    rotate3d(ax,'on');
    
    
end
hide_status_bar(main_figure);

end


function change_freq_cback_2(src,~,TS_f_per,f_vec,X,hx,ax,type)

switch type
    case 'f'
        f_val=get(src,'value')*1e3;
        [~,idx_freq]=nanmin(abs(f_vec-f_val));
        
        set(hx,'Cdata',squeeze(TS_f_per(:,idx_freq,:)),'XData',squeeze(X(:,idx_freq,:)),'alphadata',double(squeeze(TS_f_per(:,idx_freq,:))>ax.CLim(1)));
        
        xlabel(ax,sprintf('%.1fkHz',f_vec(idx_freq)/1e3));
        
    case 'p'
        sl_min = get(src,'min');
        sl_max = get(src,'max');
        sl_val = get(src,'value');
        f_val = (sl_min + sl_max) - sl_val;
        
        [~,ip]=nanmin(abs(f_vec-f_val));
        
        set(hx,'Cdata',squeeze(TS_f_per(ip,:,:)),'YData',squeeze(X(ip,:,:)),'alphadata',double(squeeze(TS_f_per(ip,:,:))>ax.CLim(1)));
        ylabel(ax,sprintf('Ping Number %.0f',f_vec(ip)));
end

end
%
% function change_freq_cback(src,~,TS_f,f_vec,im,ax)
%
% f_val=get(src,'value');
% [~,idx_freq]=nanmin(abs(f_vec/1e3-f_val));
%
% set(im,'Cdata',TS_f(:,:,idx_freq)','alphadata',double(TS_f(:,:,idx_freq)'>ax.CLim(1)));
% title(ax,sprintf('%.0fkHz',f_vec(idx_freq)/1e3));
%
% grid(ax,'on');
%
% end