%% activate_region_callback.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |obj|: TODO: write description and info on variable
% * |ID|: TODO: write description and info on variable
% * |main_figure|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function activate_region_callback(ID,main_figure,repos)

if isempty(ID)
    return;
end
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);
reg_curr=trans_obj.get_region_from_Unique_ID(ID);


if~isdeployed()
    fprintf('Activate region %.0f\n',reg_curr.ID);
end

if ~ismember(curr_disp.CursorMode,{'Normal','Create Region','Zoom In','Zoom Out'})
     return;
end


[ac_data_col,ac_bad_data_col,in_data_col,in_bad_data_col,txt_col]=set_region_colors(curr_disp.Cmap);

axes_panel_comp=getappdata(main_figure,'Axes_panel');
mini_ax_comp=getappdata(main_figure,'Mini_axes');

if repos>0
    xdata=trans_obj.get_transceiver_pings();
    ydata=trans_obj.get_transceiver_samples();
    
    x_reg_lim=xdata(reg_curr.Idx_pings);
    y_reg_lim=ydata(reg_curr.Idx_r);
    
    
    ah=axes_panel_comp.main_axes;
    x_lim=get(ah,'xlim');
    y_lim=get(ah,'ylim');
    
    if all(x_reg_lim>x_lim(2)|x_reg_lim<x_lim(1))||all(y_reg_lim>y_lim(2)|y_reg_lim<y_lim(1))
        
        dx=nanmax(diff(x_lim),(x_reg_lim(end)-x_reg_lim(1)));
        dy=nanmax(diff(y_lim),(y_reg_lim(end)-y_reg_lim(1)));
        
        x_lim_new= [nanmean(x_reg_lim)-dx/2 nanmean(x_reg_lim)+dx/2];
        y_lim_new= [nanmean(y_reg_lim)-dy/2 nanmean(y_reg_lim)+dy/2];
        
        set(ah,'XLim',x_lim_new,'YLim',y_lim_new);
    end
end
ah=[axes_panel_comp.main_axes mini_ax_comp.mini_ax];


for i=1:length(ah)
    reg_text=findobj(ah(i),'Tag','region_text');
    set(reg_text,'color',txt_col);
    
    for ireg=1:numel(trans_obj.Regions)
        if trans_obj.Regions(ireg).Unique_ID==reg_curr.Unique_ID
           
            col=ac_data_col;
            switch trans_obj.Regions(ireg).Type
                case 'Data'
                    col=ac_data_col;
                case 'Bad Data'
                    col=ac_bad_data_col;
            end
        else
            switch trans_obj.Regions(ireg).Type
                case 'Data'
                    col=in_data_col;
                case 'Bad Data'
                    col=in_bad_data_col;
            end
        end
        reg_lines_ac=findobj(ah(i),{'Tag','region','-or','Tag','region_cont'},'-and','UserData',trans_obj.Regions(ireg).Unique_ID,'-and','Type','line','-not','color',col);
        set(reg_lines_ac,'color',col);
        if ~isempty(reg_lines_ac)
            reg_image_ac=findobj(ah(i),{'Tag','region','-or','Tag','region_cont'},'-and','UserData',trans_obj.Regions(ireg).Unique_ID,'-and','Type','Image','-not','color',col);
            
            if ~isempty(reg_image_ac)
                cdata=get(reg_image_ac,'CData');
                cdata(:,:,1)=col(1);
                cdata(:,:,2)=col(2);
                cdata(:,:,3)=col(3);
                set(reg_image_ac,'Cdata',cdata);
            end
        end
        reg_patch_ac=findobj(ah(i),{'Tag','region','-or','Tag','region_cont'},'-and','UserData',trans_obj.Regions(ireg).Unique_ID,'-and','Type','Patch','-not','FaceColor',col);
        set(reg_patch_ac,'FaceColor',col,'EdgeColor',col);
    end 
end

setappdata(main_figure,'Layer',layer);

     
end








