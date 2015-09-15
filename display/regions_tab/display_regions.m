function display_regions(main_figure)

layer=getappdata(main_figure,'Layer');
region_tab_comp=getappdata(main_figure,'Region_tab');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

main_axes=axes_panel_comp.main_axes;
main_echo=axes_panel_comp.main_echo;

u=get(main_axes,'children');

for ii=1:length(u)
    if strcmp(get(u(ii),'tag'),'region')
        delete(u(ii));
    end
end
    

x=double(get(main_echo,'xdata'));
y=double(get(main_echo,'ydata'));

idx_freq=find_freq_idx(layer,curr_disp.Freq);
%idx_x0=double(layer.Transceivers(idx_freq).Data.Number(1)-1);

list_reg = list_regions(layer.Transceivers(idx_freq));
axes(main_axes)

active_reg=get(region_tab_comp.tog_reg,'value');
if curr_disp.DispReg>0
    vis='on';
else
    vis='off';
end


    for i=1:length(list_reg)
        reg_curr=layer.Transceivers(idx_freq).Regions(i);
        if i==active_reg
            col='r';
        else
            col='k';
        end
        
        switch reg_curr.Shape
            case 'Rectangular'
                x_reg=x([reg_curr.Idx_pings(1) reg_curr.Idx_pings(end) reg_curr.Idx_pings(end) reg_curr.Idx_pings(1) reg_curr.Idx_pings(1)]);
                y_reg=y([reg_curr.Idx_r(1) reg_curr.Idx_r(1) reg_curr.Idx_r(end) reg_curr.Idx_r(end) reg_curr.Idx_r(1)]);

                
%                 x_grid_idx=round(reg_curr.Output.Ping_M);
%                 y_grid_idx=round(reg_curr.Output.Sample_M);
%                 idx_nan=isnan(x_grid_idx)|isnan(y_grid_idx);
%                 x_grid_idx(idx_nan)=[];
%                 y_grid_idx(idx_nan)=[];
%                 
%                 x_grid=x(x_grid_idx(:));
%                 y_grid=y(y_grid_idx(:));
%                 
%                 plot(x_grid,y_grid,'k','linewidth',2,'tag','region','visible',vis);
%                 
                
                plot(x_reg,y_reg,col,'linewidth',1,'tag','region','visible',vis);

                
                text(nanmean(x_reg(:)),nanmean(y_reg(:)),reg_curr.Tag,'visible',vis,'FontWeight','Bold','Fontsize',12,'tag','region')
            case 'Polygon'
                idx_x=reg_curr.X_cont;
                idx_y=reg_curr.Y_cont;
                x_reg=cell(1,length(idx_x));
                y_reg=cell(1,length(idx_x));
                
                len=0;
                for jj=1:length(idx_x)
                    idx_x{jj}=idx_x{jj}+reg_curr.Idx_pings(1);
                    idx_y{jj}=idx_y{jj}+reg_curr.Idx_r(1);

                    x_reg{jj}=x(idx_x{jj});
                    y_reg{jj}=y(idx_y{jj});
                    
                    if length(idx_x)>len
                        x_text=nanmean(x_reg{jj});
                        y_text=nanmean(y_reg{jj});
                    end
                    
                    plot(x_reg{jj},y_reg{jj},col,'linewidth',1,'tag','region','visible',vis);
                end
                 text(x_text,y_text,reg_curr.Tag,'visible',vis,'FontWeight','Bold','Fontsize',10,'tag','region')
        end
    end

end

