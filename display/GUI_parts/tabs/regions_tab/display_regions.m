
function display_regions(main_figure)

layer=getappdata(main_figure,'Layer');
region_tab_comp=getappdata(main_figure,'Region_tab');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

switch curr_disp.Cmap
    
    case 'esp2'
        ac_data_col='g';
        in_data_col='b';
        bad_data_col=[0.6 0.6 0.6];
    otherwise
        ac_data_col='g';
        in_data_col='b';
        bad_data_col=[0.5 0.5 0.5];
        
end

main_axes=axes_panel_comp.main_axes;

u=findobj(main_axes,'tag','region','-or','tag','region_text');

delete(u);


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

x_lim=get(main_axes,'xlim');
y_lim=get(main_axes,'ylim');

rect_lim_x=[x_lim(1) x_lim(2) x_lim(2) x_lim(1) x_lim(1)];
rect_lim_y=[y_lim(1) y_lim(1) y_lim(2) y_lim(2) y_lim(1)];


list_reg = trans.regions_to_str();

active_reg=get(region_tab_comp.tog_reg,'value');
vis=curr_disp.DispReg;


for i=1:length(list_reg)
    reg_curr=trans.Regions(i);
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
    
    
    
    
    switch reg_curr.Shape
        case 'Rectangular'
            
            vis_grid=vis;
            x_text=nanmean(x_reg_rect(:));
            y_text=nanmean(y_reg_rect(:));

            reg_plot=patch(x_reg_rect,y_reg_rect,col,'FaceAlpha',.4,'EdgeColor',col,'tag','region','PickableParts','all','visible',vis_grid,'UserData',reg_curr.Unique_ID,'parent',main_axes);
        case 'Polygon'
            
            idx_x=reg_curr.X_cont;
            idx_y=reg_curr.Y_cont;
            x_reg=cell(1,length(idx_x));
            y_reg=cell(1,length(idx_x));
            
            nb_cont=length(idx_x);

            for jj=1:nb_cont
                
                idx_x{jj}=idx_x{jj}+reg_curr.Idx_pings(1);
                idx_y{jj}=idx_y{jj}+reg_curr.Idx_r(1);
                
                x_reg{jj}=x(idx_x{jj});
                y_reg{jj}=y(idx_y{jj})';
                
                if ~isempty(idx_x)>0
                    x_text=nanmean(x_reg{jj});
                    y_text=nanmean(y_reg{jj});
                end
             
            end
            [x_reg,y_reg]=poly2cw(x_reg,y_reg);
            [f, v] = poly2fv(x_reg,y_reg);
            reg_plot=patch('Faces', f, 'Vertices', v, 'FaceColor',col,'FaceAlpha',0.4,'EdgeColor','none','tag','region','PickableParts','all','visible',vis,'UserData',reg_curr.Unique_ID,'parent',main_axes);
           
                    
    end
    
    
    text(x_text,y_text,reg_curr.Tag,'visible',vis,'FontWeight','Bold','Fontsize',10,'tag','region_text','parent',main_axes);
    
    
    create_region_context_menu(reg_plot,main_figure,reg_curr);
    
end

end

