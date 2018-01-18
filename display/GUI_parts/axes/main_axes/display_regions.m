
function display_regions(main_figure,varargin)

% profile on;
if ~isdeployed
    disp('Display regions')
end

layer=getappdata(main_figure,'Layer');

axes_panel_comp=getappdata(main_figure,'Axes_panel');

curr_disp=getappdata(main_figure,'Curr_disp');


[ac_data_col,ac_bad_data_col,in_data_col,in_bad_data_col,txt_col]=set_region_colors(curr_disp.Cmap);

if ~isempty(varargin)
    if ischar(varargin{1})
        switch varargin{1}
            case 'both'
                main_or_mini={'main' 'mini' curr_disp.ChannelID};
            case 'mini'
                main_or_mini={'mini'};
            case 'main'
                main_or_mini={'main' curr_disp.ChannelID};
            case 'all'
                main_or_mini=union({'main' 'mini'},layer.ChannelID);
        end
    elseif iscell(varargin{1})
        main_or_mini=varargin{1};
    end
else
    main_or_mini=union({'main' 'mini'},layer.ChannelID);
end

[~,main_axes_tot,~,trans_obj,text_size,cids]=get_axis_from_cids(main_figure,main_or_mini);


for iax=1:length(main_axes_tot)
    trans=trans_obj{iax};
    
    switch curr_disp.DispReg
        case 'off'
           alpha_in=0;
        case 'on'
           alpha_in=0.4;
    end
    
    main_axes=main_axes_tot(iax);
    
    
    active_regs=trans.find_regions_Unique_ID(curr_disp.Active_reg_ID);
    
    reg_h=findobj(main_axes,{'tag','region','-or','tag','region_text','-or','tag','region_cont'});
    
    if~isempty(reg_h)
        id_disp=get(reg_h,'UserData');
        id_reg=trans.get_reg_Unique_IDs();
        id_rem = setdiff(id_disp,id_reg);
        
        if~isempty(id_rem)
            clear_regions(main_figure,id_rem,union({'main' 'mini'}, cids{iax}));
        end        
    end
    
    nb_reg=numel(trans.Regions);
    %reg_graph_obj=findobj(main_axes,{'tag','region','-or','tag','region_cont'},'-depth',1);
    reg_text_obj=findobj(main_axes,{'tag','region_text'},'-depth',1);
    
    for i=1:nb_reg
        try
            reg_curr=trans.Regions(i);
            
            if ~isempty(reg_text_obj)
                id_text=findall(reg_text_obj,'UserData',reg_curr.Unique_ID,'-depth',0);
                if ~isempty(id_text)
                    set(id_text,'String',reg_curr.disp_str());
                    continue;
                end
                
            end
            
            if any(i==active_regs)
                
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
            
                       
            reg_plot(1)=plot(main_axes,reg_curr.Poly, 'FaceColor',col,...
                'parent',main_axes,'FaceAlpha',alpha_in,...
                'EdgeColor',col,...
                'LineWidth',1,...
                'tag','region',...
                'UserData',reg_curr.Unique_ID);
            
            reg_plot(2)=text(nanmean(reg_curr.Idx_pings),nanmean(reg_curr.Idx_r),reg_curr.disp_str(),'FontWeight','Bold','Fontsize',...
                text_size(iax),'Tag','region_text','color',txt_col,'parent',main_axes,'UserData',reg_curr.Unique_ID,'Clipping', 'on');
            
            for ii=1:length(reg_plot)
                iptaddcallback(reg_plot(ii),'ButtonDownFcn',{@set_active_reg,reg_curr.Unique_ID,main_figure});
                iptaddcallback(reg_plot(ii),'ButtonDownFcn',{@move_reg_callback,reg_curr.Unique_ID,main_figure});
            end
            
            if main_axes==axes_panel_comp.main_axes
                create_region_context_menu(reg_plot,main_figure,reg_curr.Unique_ID);
                enterFcn =  @(figHandle, currentPoint)...
                    set(figHandle, 'Pointer', 'hand');
                iptSetPointerBehavior(reg_plot,enterFcn);
            end
        catch
            warning('Error display region ID %.0f',reg_curr.ID);
        end
    end
    %     profile off;
    %     profile viewer;
    
    
end

