%% mark_bad_transmit.m
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
% * |src|: TODO: write description and info on variable
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
function mark_bad_transmit(src,~,main_figure)
%profile on;

if check_axes_tab(main_figure)==0
    return;
end

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
ah=axes_panel_comp.main_axes;

if gca~=ah
    return;
end

clear_lines(ah);


[~,idx_ping_ori]=get_ori(layer,curr_disp,axes_panel_comp.main_echo);
xdata=double(get(axes_panel_comp.main_echo,'XData'));
ydata=double(get(axes_panel_comp.main_echo,'YData'));

trans_obj=layer.get_trans(curr_disp.Freq);

old_bot=trans_obj.Bottom;


if strcmp(src.SelectionType,'normal')
    set_val=0;
elseif  strcmp(src.SelectionType,'alt')
    set_val=1;
else
    set_val=0;
end



switch lower(curr_disp.Cmap)
    case 'esp2'
        line_col='w';
    otherwise
        line_col='k';
        
end


cp = ah.CurrentPoint;
xinit = cp(1,1);
yinit= cp(1,2);

if xinit<xdata(1)||xinit>xdata(end)||yinit<ydata(1)||yinit>ydata(end)
    return
end



switch src.SelectionType
    case {'normal','alt'}
 
        x_bad=[xinit xinit];
        replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2,'interaction_fcn',@wbmcb);
        replace_interaction(main_figure,'interaction','WindowButtonUpFcn','id',1,'interaction_fcn',@wbucb);
        hp=plot(ah,x_bad,[yinit yinit],'color',line_col,'linewidth',1,'marker','x');
        
    otherwise
        [~,idx_bad]=min(abs(xdata-xinit));

        trans_obj.addBadSector(idx_bad+idx_ping_ori-1,set_val);

        end_bt_edit();
end
    function wbmcb(~,~)
        
        cp = ah.CurrentPoint;
        
        X = sort([xinit ,cp(1,1)]);
        Y=  [cp(1,2),cp(1,2)];
        
        x_min=nanmin(X);
        x_min=nanmax(xdata(1),x_min);
        
        x_max=nanmax(X);
        x_max=nanmin(xdata(end),x_max);
        
        x_bad=[x_min x_max];
        
        set(hp,'XData',x_bad,'YData',Y);
    end

    function wbucb(src,~)
     
        delete(hp);

        [~,idx_start]=min(abs(xdata-min(x_bad)));
        [~,idx_end]=min(abs(xdata-max(x_bad)));
        idx_f=(idx_start:idx_end)+idx_ping_ori-1;
        
    
        trans_obj.addBadSector(idx_f,set_val);

            
        end_bt_edit()
        
    end

    function end_bt_edit()
        replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2);
        replace_interaction(main_figure,'interaction','WindowButtonUpFcn','id',1);
        %reset_disp_info(main_figure);
        
        
        new_bot=trans_obj.Bottom;
        curr_disp.Bot_changed_flag=1; 
        
        setappdata(main_figure,'Curr_disp',curr_disp);
        setappdata(main_figure,'Layer',layer);
        
        add_undo_bottom_action(main_figure,trans_obj,old_bot,new_bot);
        
        display_bottom(main_figure);
        set_alpha_map(main_figure);
        update_mini_ax(main_figure,0);
%         profile off;
%         profile viewer;
    end

end
