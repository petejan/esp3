
function display_regions(main_figure,varargin)

%profile on;
if ~isdeployed
    disp('Display regions')
end

layer=getappdata(main_figure,'Layer');
region_tab_comp=getappdata(main_figure,'Region_tab');
axes_panel_comp=getappdata(main_figure,'Axes_panel');

curr_disp=getappdata(main_figure,'Curr_disp');


[ac_data_col,ac_bad_data_col,in_data_col,in_bad_data_col,txt_col]=set_region_colors(curr_disp.Cmap);



if ~isempty(varargin)
    mini_ax_comp=getappdata(main_figure,'Mini_axes');
    switch varargin{1}
        case 'both'
            main_axes_tot=[mini_ax_comp.mini_ax axes_panel_comp.main_axes];
        case 'mini'
            main_axes_tot=mini_ax_comp.mini_ax;
        case 'main'
            main_axes_tot=axes_panel_comp.main_axes;
            
    end
else
    main_axes_tot=axes_panel_comp.main_axes;
end
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);

Number=trans.get_transceiver_pings();
Range=trans.get_transceiver_range();

xdata=Number;

x=xdata;
y=Range;

alpha_in=0.4;
for iax=1:length(main_axes_tot)
    main_axes=main_axes_tot(iax);
    
    
    
    x_lim=get(main_axes,'xlim');
    y_lim=get(main_axes,'ylim');
    
    rect_lim_x=[x_lim(1) x_lim(2) x_lim(2) x_lim(1) x_lim(1)];
    rect_lim_y=[y_lim(1) y_lim(1) y_lim(2) y_lim(2) y_lim(1)];
    
    
    active_reg=get(region_tab_comp.tog_reg,'value');
    reg_h=findobj(main_axes,{'tag','region','-or','tag','region_text','-or','tag','region_cont'});
    
    if~isempty(reg_h)
        id_disp=(get(reg_h,'UserData'));
        id_disp=unique([id_disp{:}]);
        id_reg=trans.get_reg_Unique_IDs();
        id_rem = setdiff(id_disp,id_reg);
        if~isempty(id_rem)
            clear_regions(main_figure,id_rem);
        end
    end
    
    nb_reg=numel(trans.Regions);
    for i=1:nb_reg
        try
            reg_curr=trans.Regions(i);
            id_reg=findobj(main_axes,{'tag','region','-or','tag','region_text','-or','tag','region_cont'},'-and','UserData',reg_curr.Unique_ID);
           
            
            if ~isempty(id_reg)
                id_text=findobj(main_axes,{'tag','region_text'},'-and','UserData',reg_curr.Unique_ID);
                if ~isempty(id_text)
                    set(id_text,'String',reg_curr.Tag);
                end
                continue;
            end
            
            if i==active_reg
                
                switch lower(reg_curr.Type)
                    case 'data'
                        col=ac_data_col;
                    case 'bad data'
                        col=ac_bad_data_col;
                end
            else
                
                switch lower(reg_curr.Type)
                    case 'data'
                        col=in_data_col;
                    case 'bad data'
                        col=in_bad_data_col;
                end
            end
            x_reg_rect=x([reg_curr.Idx_pings(1) reg_curr.Idx_pings(end) reg_curr.Idx_pings(end) reg_curr.Idx_pings(1) reg_curr.Idx_pings(1)]);
            y_reg_rect=y([reg_curr.Idx_r(end) reg_curr.Idx_r(end) reg_curr.Idx_r(1) reg_curr.Idx_r(1) reg_curr.Idx_r(end)]);
            
            
%             x_reg_poly=[x(reg_curr.Idx_pings(:)') x(reg_curr.Idx_pings(end))*ones(size(reg_curr.Idx_r(:)')) x(reg_curr.Idx_pings) x(reg_curr.Idx_pings(1))*ones(size(reg_curr.Idx_r(:)'))];
%             y_reg_poly=[y(reg_curr.Idx_r(1))*ones(size(reg_curr.Idx_pings(:)))' y(reg_curr.Idx_r(:))' y(reg_curr.Idx_r(end))*ones(size(reg_curr.Idx_pings(:)))' y(reg_curr.Idx_r(:))'];
%             
%             if ~any(inpolygon(x_reg_poly,y_reg_poly,rect_lim_x,rect_lim_y))&&~any(inpolygon(rect_lim_x,rect_lim_y,x_reg_rect,y_reg_rect))
%                 continue;
%             end
%             
            
            switch reg_curr.Shape
                case 'Rectangular'
                    reg_plot=gobjects(1,2);
                    %cdata=zeros(length(reg_curr.Idx_r),length(reg_curr.Idx_pings),3);
                    %cdata(:,:,1)=col(1);
                    %cdata(:,:,2)=col(2);
                    %cdata(:,:,3)=col(3);
                    
                    %reg_plot(1)=image('XData',x(reg_curr.Idx_pings),'YData',y(reg_curr.Idx_r),'CData',cdata,'parent',main_axes,'tag','region','UserData',reg_curr.Unique_ID,'AlphaData',alpha_in,'visible',curr_disp.DispReg);
                    plot(main_axes,x_reg_rect,y_reg_rect,'color',col,'LineWidth',1,'Tag','region_cont','UserData',reg_curr.Unique_ID);
                    
                    reg_plot(1)=patch('XData',x_reg_rect(1:4),'YData',y_reg_rect(1:4),'FaceColor',col,'parent',main_axes,'FaceAlpha',alpha_in,'EdgeColor',col,'tag','region','UserData',reg_curr.Unique_ID,'visible',curr_disp.DispReg);
                    
                    
                    x_text=nanmean(x_reg_rect(:));
                    y_text=nanmean(y_reg_rect(:));
                    
                case 'Polygon'
                    reg_plot=gobjects(1,3);
                    cdata=zeros(length(reg_curr.Idx_r),length(reg_curr.Idx_pings),3);
                    cdata(:,:,1)=col(1);
                    cdata(:,:,2)=col(2);
                    cdata(:,:,3)=col(3);
                    
                    idx_x=reg_curr.X_cont;
                    idx_y=reg_curr.Y_cont;
                    idx_x_out=cell(1,length(idx_x));
                    idx_y_out=cell(1,length(idx_x));
                    
                    x_reg=cell(1,length(idx_x));
                    y_reg=cell(1,length(idx_x));
                    
                    nb_cont=length(idx_x);
                    len_cont=0;
                    x_text=0;
                    y_text=0;
                    x_max=[];
                    y_max=[];
                    for jj=1:nb_cont
                        
                        idx_x_out{jj}=idx_x{jj}+reg_curr.Idx_pings(1)-1;
                        idx_y_out{jj}=idx_y{jj}+reg_curr.Idx_r(1)-1;
                        try
                            x_reg{jj}=x(idx_x_out{jj});
                            y_reg{jj}=y(idx_y_out{jj})';
                        catch%TOFIX
                            if ~isdeployed
                                warning('Error in polygon region display for region ID %.0f',reg_curr.ID);
                            end
                            continue;
                        end
                        len_cont_curr=length(x_reg{jj});
                        if ~isempty(idx_x)&&len_cont_curr>=len_cont
                            x_max=x_reg{jj};
                            y_max=y_reg{jj};
                            len_cont=len_cont_curr;
                            x_text=nanmean(x_reg{jj});
                            y_text=nanmean(y_reg{jj});
                        end
                        if ~any(strcmpi(reg_curr.Name,'school'))||len_cont_curr>500
                            line(x_reg{jj},y_reg{jj},'color',col,'LineWidth',1,'parent',main_axes,'tag','region_cont','UserData',reg_curr.Unique_ID);
                        end
                    end
                    line(x_max,y_max,'color',col,'LineWidth',1,'parent',main_axes,'tag','region_cont','UserData',reg_curr.Unique_ID);
                    
                    reg_plot(1)=image('XData',x(reg_curr.Idx_pings),'YData',y(reg_curr.Idx_r),'CData',cdata,'parent',main_axes,'tag','region','UserData',reg_curr.Unique_ID,'AlphaData',alpha_in*(reg_curr.MaskReg>0),'visible',curr_disp.DispReg);
                    reg_plot(3)=line(x_max,y_max,'color',col,'LineWidth',1,'parent',main_axes,'tag','region_cont','UserData',reg_curr.Unique_ID);
                    
            end
            
            
            reg_plot(2)=text(x_text,y_text,reg_curr.Tag,'FontWeight','Bold','Fontsize',10,'Tag','region_text','color',txt_col,'parent',main_axes,'UserData',reg_curr.Unique_ID);
            
            
            if main_axes==axes_panel_comp.main_axes
                create_region_context_menu(reg_plot,main_figure,reg_curr);
                enterFcn =  @(figHandle, currentPoint)...
                    set(figHandle, 'Pointer', 'hand');
                iptSetPointerBehavior(reg_plot,enterFcn);
            end
        catch
            warning('Error display region ID %.0f',reg_curr.ID);
        end
    end
    if nb_reg>0
        activate_region_callback([],[],trans.Regions(active_reg),main_figure,0);
    end
    %     profile off;
    %     profile viewer;
end

