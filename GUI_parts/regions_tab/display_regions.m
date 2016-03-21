
function display_regions(main_figure)

layer=getappdata(main_figure,'Layer');
region_tab_comp=getappdata(main_figure,'Region_tab');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

main_axes=axes_panel_comp.main_axes;

u=get(main_axes,'children');

for ii=1:length(u)
    if strcmp(get(u(ii),'tag'),'region')
        delete(u(ii));
    end
end

idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);

if isempty(trans.Regions)
    return; 
end

Number=trans.Data.get_numbers();
Range=trans.Data.get_range();

xdata=Number;

x=xdata;
y=Range;

list_reg = trans.regions_to_str();
axes(main_axes);
dr=nanmean(diff(trans.Data.get_range()));
dp=nanmean(diff(trans.GPSDataPing.Dist));

active_reg=get(region_tab_comp.tog_reg,'value');
vis=curr_disp.DispReg;


    for i=1:length(list_reg)
        reg_curr=trans.Regions(i);
        if i==active_reg
            col='r';
        else
            switch lower(reg_curr.Type)
                case 'data'
                    col='b';
                case 'bad data'
                    col=[0.7 0.7 0.7];
            end
        end
        

        x_reg_rect=x([reg_curr.Idx_pings(1) reg_curr.Idx_pings(end) reg_curr.Idx_pings(end) reg_curr.Idx_pings(1) reg_curr.Idx_pings(1)]);
        y_reg_rect=y([reg_curr.Idx_r(1) reg_curr.Idx_r(1) reg_curr.Idx_r(end) reg_curr.Idx_r(end) reg_curr.Idx_r(1)]);
        
        switch reg_curr.Cell_h_unit
            case 'meters'
                dy=ceil(reg_curr.Cell_h/dr);
            otherwise
                dy=reg_curr.Cell_h;
        end
        
        switch reg_curr.Cell_w_unit
            case 'meters'
                dx=ceil(reg_curr.Cell_w/dp);
            otherwise
                dx=reg_curr.Cell_w;
        end
        
        
        if strcmp(reg_curr.Name,'Track')
            x_grid=[];
            y_grid=[];
        else
            x_grid=x([reg_curr.Idx_pings(1):dx:reg_curr.Idx_pings(end) reg_curr.Idx_pings(end)]);
            y_grid=y([reg_curr.Idx_r(1):dy:reg_curr.Idx_r(end) reg_curr.Idx_r(end)]);
        end
        [X_grid,Y_grid]=meshgrid(x_grid,y_grid);
        
        
        switch reg_curr.Shape
            case 'Rectangular'       

                vis_grid=vis;
                x_text=nanmean(x_reg_rect(:));
                y_text=nanmean(y_reg_rect(:));
                nb_cont=1;
                reg_plot=gobjects(1,length(x_grid)+length(y_grid)+1);
                reg_plot(1)=plot(x_reg_rect,y_reg_rect,'color',col,'linewidth',1,'linestyle','-','tag','region','PickableParts','all','visible',vis_grid);
            case 'Polygon'

                idx_x=reg_curr.X_cont;
                idx_y=reg_curr.Y_cont;
                x_reg=cell(1,length(idx_x));
                y_reg=cell(1,length(idx_x));

                nb_cont=length(idx_x);
                reg_plot=gobjects(1,length(x_grid)+length(y_grid)+nb_cont);
                 
                for jj=1:length(idx_x)

                    idx_x{jj}=idx_x{jj}+reg_curr.Idx_pings(1);
                    idx_y{jj}=idx_y{jj}+reg_curr.Idx_r(1);

                    x_reg{jj}=x(idx_x{jj});
                    y_reg{jj}=y(idx_y{jj});
                    
                    if ~isempty(idx_x)>0
                        x_text=nanmean(x_reg{jj});
                        y_text=nanmean(y_reg{jj});
                    end   
                   
                    reg_plot(jj)=plot(x_reg{jj},y_reg{jj},'color',col,'linewidth',1,'tag','region','PickableParts','all','visible',vis); 
                end
                if strcmp(reg_curr.Name,'Track')
                   grid_in=zeros(size(x_grid)); 
                else
                    grid_in=grid_mask_from_cont(Y_grid,X_grid,y_reg,x_reg);   
                end
                
                X_grid(~grid_in)=nan;
                Y_grid(~grid_in)=nan;

                 
        end

            for uui=1:size(X_grid,1)
                reg_plot(uui+nb_cont)=plot(X_grid(uui,:),Y_grid(uui,:),'color',col,'linewidth',0.1,'linestyle','-','tag','region','PickableParts','all','visible',vis);
            end
            for uuj=1:size(X_grid,2)
                reg_plot(uuj+size(X_grid,1)+nb_cont)=plot(X_grid(:,uuj),Y_grid(:,uuj),'color',col,'linewidth',0.1,'linestyle','-','tag','region','PickableParts','all','visible',vis);
            end

        text(x_text,y_text,reg_curr.Tag,'visible',vis,'FontWeight','Bold','Fontsize',10,'tag','region');
        

        create_region_context_menu(reg_plot,main_figure,reg_curr);
       
    end

end

