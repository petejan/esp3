
function [TS_f,f_vec]=freq_response_sp_mat_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

region_tab_comp=getappdata(main_figure,'Region_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);
list_reg = layer.Transceivers(idx_freq).regions_to_str();

if ~isempty(list_reg)
    show_status_bar(main_figure);
    load_bar_comp=getappdata(main_figure,'Loading_bar');
    active_reg=trans_obj.Regions(get(region_tab_comp.tog_reg,'value'));
    
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
        [cmap,~,~,col_grid,~]=init_cmap(curr_disp.Cmap);
        

        [TS_f,f_vec,pings,range]=trans_obj.TS_f_from_region(active_reg,'envdata',layer.EnvData,'cal',cal,'dp',3,'load_bar_comp',load_bar_comp);
        [~,idx_freq]=nanmin(abs(f_vec/1e3-floor(nanmean(f_vec/1e3))));
        
        fig=new_echo_figure([]);
        ax=axes(fig,'units','normalized','Position',[0.1 0.2 0.85 0.7]);
        im=imagesc(ax,pings,range,TS_f(:,:,idx_freq)');
        title(ax,sprintf('%.0fkHz',f_vec(idx_freq)/1e3));
        ylabel(ax,'Range(m)');
        xlabel(ax,'Ping Number');
        axis(ax,'ij');
        colormap(ax,cmap);
        caxis(ax,curr_disp.getCaxField('sp'));
        set(ax,'GridColor',col_grid);
        caxis(curr_disp.getCaxField('sv'));
        uicontrol(fig,'Style','slider','Min',f_vec(1)/1e3,'Max',f_vec(end)/1e3,'Value',floor(nanmean(f_vec/1e3)),'SliderStep',[0.01 0.1],...
            'units','normalized','Position',[0.2 0.05 0.6 0.05],'Callback',{@change_freq_cback,TS_f,f_vec,im,ax});
        set(im,'alphadata',double(TS_f(:,:,idx_freq)'>ax.CLim(1)));
        grid(ax,'on');
        new_echo_figure(main_figure,'fig_handle',fig,'Name','Sv(f)','Tag',sprintf('Region %.0f',active_reg.Unique_ID),'Name',active_reg.print());
        colorbar(ax);
        

        
    end
    hide_status_bar(main_figure);
end
end


function change_freq_cback(src,~,TS_f,f_vec,im,ax)

f_val=get(src,'value');
[~,idx_freq]=nanmin(abs(f_vec/1e3-f_val));

set(im,'Cdata',TS_f(:,:,idx_freq)');
title(ax,sprintf('%.0fkHz',f_vec(idx_freq)/1e3));
set(im,'alphadata',double(TS_f(:,:,idx_freq)'>ax.CLim(1)));
grid(ax,'on');

end