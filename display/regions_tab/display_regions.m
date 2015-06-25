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
idx_x0=double(layer.Transceivers(idx_freq).Data.Number(1)-1);

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
                x_reg=[x(reg_curr.Ping_ori-idx_x0) x(reg_curr.Ping_ori-idx_x0+reg_curr.BBox_w-1) x(reg_curr.Ping_ori-idx_x0+reg_curr.BBox_w-1) x(reg_curr.Ping_ori-idx_x0) x(reg_curr.Ping_ori-idx_x0)];
                y_reg=[y(reg_curr.Sample_ori) y(reg_curr.Sample_ori) y(reg_curr.Sample_ori+reg_curr.BBox_h-1) y(reg_curr.Sample_ori+reg_curr.BBox_h-1) y(reg_curr.Sample_ori)];
                plot(x_reg,y_reg,col,'linewidth',1,'tag','region','visible',vis);
            case 'Polygon'
                idx_x=reg_curr.X_cont;
                idx_y=reg_curr.Y_cont;
                x_reg=cell(1,length(idx_x));
                y_reg=cell(1,length(idx_x));
                for jj=1:length(idx_x)
                    idx_x{jj}=idx_x{jj}+reg_curr.Ping_ori-idx_x0-1;
                    idx_y{jj}=idx_y{jj}+reg_curr.Sample_ori-1;

                    x_reg{jj}=x(idx_x{jj});
                    y_reg{jj}=y(idx_y{jj});
                    plot(x_reg{jj},y_reg{jj},col,'linewidth',1,'tag','region','visible',vis);
                end
        end
    end

end

