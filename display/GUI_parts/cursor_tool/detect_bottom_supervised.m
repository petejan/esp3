%% detect_bottom_supervised.m
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
% * |cbackdata|: TODO: write description and info on variable
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
% * 2017-06-28: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function detect_bottom_supervised(src,~,main_figure)
if~(strcmpi(src.SelectionType,'Normal'))
    return;
end
update_algos(main_figure);
layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

trans_obj=layer.get_trans(curr_disp.Freq);
context_menu=axes_panel_comp.bad_transmits.UIContextMenu;
childs=findall(context_menu,'Type','uimenu');

for i=1:length(childs)
    if strcmp(childs(i).Checked,'on')
        dr=childs(i).UserData;
        break;
    end
    
end
Range= trans_obj.get_transceiver_range();
id=nanmean(diff(Range));
t=trans_obj.get_transceiver_time();
dt=(t(2)-t(1))*(24*60*60);
ratio=ceil(dt/id);

ah=axes_panel_comp.main_axes;

clear_lines(ah);

switch lower(curr_disp.Cmap)
    case 'esp2'
        line_col=[0 0.5 0];
    otherwise
        line_col='r';
        
end


xdata=trans_obj.get_transceiver_pings();
ydata=trans_obj.get_transceiver_samples();

x_lim=get(ah,'xlim');
y_lim=get(ah,'ylim');


nb_pings=numel(xdata);
nb_samples=numel(ydata);
old_bot=trans_obj.Bottom;

yinit=nan(1,nb_pings);
if isempty(old_bot.Sample_idx)
    old_bot.Sample_idx=nan(1,nb_pings);
end

bot=old_bot;

cp = ah.CurrentPoint;
ping_init =round(cp(1,1));
sample_init=round(cp(1,2));

if ping_init<x_lim(1)||ping_init>x_lim(end)||sample_init<y_lim(1)||sample_init>y_lim(end)
    return;
end

switch src.SelectionType
    case 'normal'
        replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2,'interaction_fcn',@wbmcb);
        replace_interaction(main_figure,'interaction','WindowButtonUpFcn','id',1,'interaction_fcn',@wbucb);
    otherwise
        return;
        
end

hp=plot(ah,xdata,yinit,'color',line_col,'linewidth',1,'Tag','bottom_temp');
rect=rectangle(ah,'Position',[ping_init-dr sample_init-ratio*dr 2*dr dr*2*ratio],'EdgeColor',line_col);
wbmcb([],[])
    function wbmcb(~,~)

        cp=ah.CurrentPoint;
        ping_new =round(cp(1,1));
        sample_new=round(cp(1,2));
        
        rect.Position=[ping_new-dr sample_new-ratio*dr 2*dr dr*2*ratio];
        
        [idx_pings,idx_r]=get_pr(ping_new,sample_new);

        if ping_new<xdata(1)||ping_new>xdata(end)||sample_new<ydata(1)||sample_new>ydata(end)
            return;
        end
        
        output_struct= trans_obj.apply_algo('BottomDetectionV2','reg_obj',region_cl('Idx_r',idx_r,'Idx_pings',idx_pings));
        
        yinit(idx_pings)=output_struct.bottom(idx_pings);
        if isvalid(hp)
            set(hp,'XData',xdata(idx_pings),'YData',yinit(idx_pings));
        else
            hp=plot(ah,xdata(idx_pings),yinit(idx_pings),'color',line_col,'linewidth',1,'Tag','bottom_temp');
        end
        
        
        bot.Sample_idx(idx_pings)=yinit(idx_pings);
        end_bottom_edit(0)
    end


    function wbucb(~,~)
        delete(hp);
        delete(rect)
        end_bottom_edit(1);
        
    end


    function [idx_pings,idx_r]=get_pr(ping1,sample1)
        
        idx_pings=(ping1-dr):(ping1+dr);
        idx_r=(sample1-dr*ratio):(sample1+dr*ratio);
        
        idx_pings(idx_pings>nb_pings|idx_pings<1)=[];
        idx_r(idx_r>nb_samples|idx_r<1)=[];
        
    end

    function end_bottom_edit(val)
        
        if val>0
            replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2);
            replace_interaction(main_figure,'interaction','WindowButtonUpFcn','id',1);
        end
        
        trans_obj.setBottom(bot);
        curr_disp.Bot_changed_flag=1;
        display_bottom(main_figure);
        

        set_alpha_map(main_figure,'update_bt',0);
        if val>0
            setappdata(main_figure,'Curr_disp',curr_disp);
            setappdata(main_figure,'Layer',layer);
            
            add_undo_bottom_action(main_figure,trans_obj,old_bot,bot);
            
            set_alpha_map(main_figure,'main_or_mini','mini','update_bt',0);
        end

    end




end
