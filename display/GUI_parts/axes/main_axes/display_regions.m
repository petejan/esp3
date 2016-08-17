
function display_regions(main_figure)

layer=getappdata(main_figure,'Layer');
region_tab_comp=getappdata(main_figure,'Region_tab');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');


switch curr_disp.Cmap
    
    case 'esp2'
        ac_data_col=[0 1 0];
        in_data_col=[1 0 0];
        bad_data_col=[0.5 0.5 0.5];
        txt_col='w';
    otherwise
        ac_data_col=[1 0 0];
        in_data_col=[0 1 0];
        bad_data_col=[0.5 0.5 0.5];
        txt_col='k';
end




%main_axes_tot=[axes_panel_comp.main_axes display_tab_comp.mini_ax];
main_axes_tot=axes_panel_comp.main_axes;

for iax=1:length(main_axes_tot)
    main_axes=main_axes_tot(iax);
    u=findobj(main_axes,'tag','region','-or','tag','region_text','-or','tag','region_cont');
    
    delete(u);
    
    
    idx_freq=find_freq_idx(layer,curr_disp.Freq);
    trans=layer.Transceivers(idx_freq);
    
    if isempty(trans.Regions)
        continue;
    end
    

     alpha_in=0.4;

     Number=trans.Data.get_numbers();
     Range=trans.Data.get_range();
%     
%     dr=nanmean(diff(Range));
%     dp=nanmean(diff(trans.GPSDataPing.Dist));
    
    xdata=Number;
    
    x=xdata;
    y=Range;
    
    x_lim=get(main_axes,'xlim');
    y_lim=get(main_axes,'ylim');
    
    rect_lim_x=[x_lim(1) x_lim(2) x_lim(2) x_lim(1) x_lim(1)];
    rect_lim_y=[y_lim(1) y_lim(1) y_lim(2) y_lim(2) y_lim(1)];
    
    
    list_reg = trans.regions_to_str();
    
    active_reg=get(region_tab_comp.tog_reg,'value');

    for i=1:length(list_reg)
        reg_curr=trans.Regions(i);
%         
%         switch reg_curr.Cell_h_unit
%             case 'meters'
%                 dy=ceil(reg_curr.Cell_h/dr);
%             otherwise
%                 dy=reg_curr.Cell_h;
%         end
%         
%         switch reg_curr.Cell_w_unit
%             case 'meters'
%                 dx=ceil(reg_curr.Cell_w/dp);
%             otherwise
%                 dx=reg_curr.Cell_w;
%         end
% 
%          if  strcmp(reg_curr.Name,'Track')
%             x_grid=[];
%             y_grid=[];
%         else
%             x_grid=x([reg_curr.Idx_pings(1):dx:reg_curr.Idx_pings(end) reg_curr.Idx_pings(end)]);
% 
%             y_grid=y([reg_curr.Idx_r(1):dy:reg_curr.Idx_r(end) reg_curr.Idx_r(end)]);
%         end
%         
%         [X_grid,Y_grid]=meshgrid(x_grid,y_grid);
       
        if i==active_reg
            col=ac_data_col;
        else
            switch lower(reg_curr.Type)
                case 'data'
                    col=in_data_col;
                case 'bad data'
                    col=bad_data_col;
            end
        end
        x_reg_rect=x([reg_curr.Idx_pings(1) reg_curr.Idx_pings(end) reg_curr.Idx_pings(end) reg_curr.Idx_pings(1) reg_curr.Idx_pings(1)]);
        y_reg_rect=y([reg_curr.Idx_r(1) reg_curr.Idx_r(1) reg_curr.Idx_r(end) reg_curr.Idx_r(end) reg_curr.Idx_r(1)]);
        
        
        x_reg_poly=[x(reg_curr.Idx_pings(:)') x(reg_curr.Idx_pings(end))*ones(size(reg_curr.Idx_r(:)')) x(reg_curr.Idx_pings) x(reg_curr.Idx_pings(1))*ones(size(reg_curr.Idx_r(:)'))];
        y_reg_poly=[y(reg_curr.Idx_r(1))*ones(size(reg_curr.Idx_pings(:)))' y(reg_curr.Idx_r(:))' y(reg_curr.Idx_r(end))*ones(size(reg_curr.Idx_pings(:)))' y(reg_curr.Idx_r(:))'];
        
        if nansum(inpolygon(x_reg_poly,y_reg_poly,rect_lim_x,rect_lim_y))==0&&nansum(inpolygon(rect_lim_x,rect_lim_y,x_reg_rect,y_reg_rect))==0
            continue;
        end
        
        
        reg_plot=gobjects(2);
        cdata=zeros(length(reg_curr.Idx_r),length(reg_curr.Idx_pings),3);
        cdata(:,:,1)=col(1);
        cdata(:,:,2)=col(2);
        cdata(:,:,3)=col(3);
         switch reg_curr.Shape
            case 'Rectangular'
            reg_plot(1)=image('XData',x(reg_curr.Idx_pings),'YData',y(reg_curr.Idx_r),'CData',cdata,'parent',main_axes,'tag','region','UserData',reg_curr.Unique_ID,'AlphaData',alpha_in,'visible',curr_disp.DispReg);
 
                x_text=nanmean(x_reg_rect(:));
                y_text=nanmean(y_reg_rect(:));
%                 plot(main_axes,X_grid,Y_grid,'color',col,'Tag','region','visible',curr_disp.DispReg,'UserData',reg_curr.Unique_ID);
%                 plot(main_axes,X_grid',Y_grid','color',col,'Tag','region','visible',curr_disp.DispReg,'UserData',reg_curr.Unique_ID);
                plot(main_axes,x_reg_rect,y_reg_rect,'color',col,'LineWidth',1,'Tag','region_cont','UserData',reg_curr.Unique_ID);
            case 'Polygon'
                
                idx_x=reg_curr.X_cont;
                idx_y=reg_curr.Y_cont;
                idx_x_out=cell(1,length(idx_x));
                idx_y_out=cell(1,length(idx_x));
                
                x_reg=cell(1,length(idx_x));
                y_reg=cell(1,length(idx_x));
                
                nb_cont=length(idx_x);
                for jj=1:nb_cont
                    
                    idx_x_out{jj}=idx_x{jj}+reg_curr.Idx_pings(1)-1;
                    idx_y_out{jj}=idx_y{jj}+reg_curr.Idx_r(1);
                    
                    x_reg{jj}=x(idx_x_out{jj});
                    y_reg{jj}=y(idx_y_out{jj})';
                    
                    if ~isempty(idx_x)
                        x_text=nanmean(x_reg{jj});
                        y_text=nanmean(y_reg{jj});
                    end
                    
                    %line(x_reg{jj},y_reg{jj},'color',col,'LineWidth',1,'parent',main_axes,'tag','region_cont','UserData',reg_curr.Unique_ID);
                end
                
%                  mask=imresize(reg_curr.MaskReg==0,size(X_grid));
%                  X_grid(mask)=nan;
%                  Y_grid(mask)=nan;

                 reg_plot(1)=image('XData',x(reg_curr.Idx_pings),'YData',y(reg_curr.Idx_r),'CData',cdata,'parent',main_axes,'tag','region','UserData',reg_curr.Unique_ID,'AlphaData',alpha_in*(reg_curr.MaskReg>0),'visible',curr_disp.DispReg);
 
%                  plot(main_axes,X_grid,Y_grid,'color',col,'Tag','region','visible',curr_disp.DispReg,'UserData',reg_curr.Unique_ID);
%                  plot(main_axes,X_grid',Y_grid','color',col,'Tag','region','visible',curr_disp.DispReg,'UserData',reg_curr.Unique_ID);
                
        end
        
        
        reg_plot(2)=text(x_text,y_text,reg_curr.Tag,'FontWeight','Bold','Fontsize',10,'Tag','region_text','color',txt_col,'parent',main_axes,'UserData',reg_curr.Unique_ID);
        
        create_region_context_menu(reg_plot,main_figure,reg_curr);
    end
    
end

end
