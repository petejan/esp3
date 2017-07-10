%% push_bottom.m
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
function push_bottom(src,~,main_figure)
if~(strcmpi(src.SelectionType,'Normal'))
   return;
end

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

context_menu=axes_panel_comp.bad_transmits.UIContextMenu;
childs=findall(context_menu,'Type','uimenu');

for i=1:length(childs)
    if strcmp(childs(i).Checked,'on')
        radius=childs(i).UserData;
        break;
    end
    
end

ah=axes_panel_comp.main_axes;

clear_lines(ah);

switch lower(curr_disp.Cmap)
    case 'esp2'
        line_col=[0 0.5 0];
    otherwise
        line_col='r';
        
end

idx_freq=find_freq_idx(layer,curr_disp.Freq);

xdata=layer.Transceivers(idx_freq).get_transceiver_pings();
ydata=layer.Transceivers(idx_freq).get_transceiver_samples();

x_lim=get(ah,'xlim');
y_lim=get(ah,'ylim');


nb_pings=numel(xdata);
nb_samples=numel(ydata);
old_bot=layer.Transceivers(idx_freq).Bottom;

if isempty(old_bot.Sample_idx)
    old_bot.Sample_idx=nan(1,nb_pings);
end

bot=old_bot;
samples_ori=bot.Sample_idx;
xinit=xdata;
yinit=nan(1,nb_pings);

cp = ah.CurrentPoint;
ping_init =round(cp(1,1));
sample_init=round(cp(1,2));


if ping_init<x_lim(1)||ping_init>x_lim(end)||sample_init<y_lim(1)||sample_init>y_lim(end)
    return;
end

circ=viscircles(ah,[ping_init sample_init], radius/2,'color','k','linewidth',1,'linestyle','--');


switch src.SelectionType
    case 'normal'
        replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2,'interaction_fcn',@wbmcb);
        replace_interaction(main_figure,'interaction','WindowButtonUpFcn','id',1,'interaction_fcn',@wbucb);
    otherwise
        return;
        
end

if sample_init>=samples_ori(ping_init)
    position='above';
    setptr(main_figure,'udrag');
else
    position='below';
    setptr(main_figure,'ddrag');
end
hp=plot(ah,xdata,yinit,'color',line_col,'linewidth',1,'Tag','bottom_temp');

    function wbmcb(~,~)
        cp=ah.CurrentPoint;
        ping_new =round(cp(1,1));
        sample_new=round(cp(1,2));
        if ping_new<xdata(1)||ping_new>xdata(end)||sample_new<ydata(1)||sample_new>ydata(end)
            return;
        end
        
        sample_new(sample_new>nb_samples)=nb_samples;
        sample_new(sample_new<0)=1;
        p0=nanmax(ping_new-radius,1);
        p1=nanmin(ping_new+radius,nb_pings);
        pings_spline=[p0 ping_new p1];
        if length(unique(pings_spline)) < length(pings_spline)
            return;
        end
        samples_spline=[samples_ori(p0) sample_new samples_ori(p1)];
        pings=p0:p1;

        samples_new = round(spline(pings_spline,samples_spline,pings));
        samples_new(samples_new>nb_samples)=nb_samples;
        samples_new(samples_new<=0)=1;
        
        delete(circ);
       
         if isvalid(circ)
             for ic=1:numel(circ.Children)
                set(circ.Children(ic),'XData',circ.Children(ic).XData-nanmean(circ.Children(ic).XData)+ping_new,...
                    'YData',circ.Children(ic).YYData-nanmean(circ.Children(ic).YData)+sample_new);
             end
        else
            circ=viscircles(ah,[ping_new sample_new],radius/2,'color','k','linewidth',1,'linestyle','--');
        end
        
        switch position
            case 'above'
                if sample_new<samples_ori(ping_new)                    
                    samples_ori(pings)=samples_new;
                    yinit(pings)=samples_new;
                else
                    return;
                end                
            case 'below'
                if sample_new>samples_ori(ping_new)                   
                    samples_ori(pings)=samples_new;
                    yinit(pings)=samples_new;
                else
                    return;
                end
                
        end
        if isvalid(hp)
            set(hp,'XData',xdata,'YData',yinit);
        else
            hp=plot(ah,xdata,yinit,'color',line_col,'linewidth',1,'Tag','bottom_temp');
        end
    end

   
    

    function [x_f, y_f]=check_xy()
        xinit(isnan(yinit))=[];
        yinit(isnan(yinit))=[];
        
        x_rem=xinit>xdata(end)|xinit<xdata(1);
        y_rem=yinit>ydata(end)|yinit<ydata(1);

        xinit(x_rem|y_rem)=[];
        yinit(x_rem|y_rem)=[];
        
        [x_f,IA,~] = unique(xinit);
        y_f=yinit(IA);
    end

    function wbucb(~,~)
        delete(circ);
        delete(hp);
        
       [x_f,y_f]=check_xy();

       bot.Sample_idx(x_f)=y_f;
       end_bottom_edit();
        
    end


   


    function end_bottom_edit()
        replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2);
        replace_interaction(main_figure,'interaction','WindowButtonUpFcn','id',1);
        layer.Transceivers(idx_freq).setBottom(bot);
        curr_disp.Bot_changed_flag=1; 
        setappdata(main_figure,'Curr_disp',curr_disp);
        setappdata(main_figure,'Layer',layer);
        
        % Prepare an undo/redo action
        cmd.Name = sprintf('Bottom Push');
        cmd.Function        = @bottom_undo_fcn;       % Redo action
        cmd.Varargin        = {main_figure,layer.Transceivers(idx_freq),bot};
        cmd.InverseFunction = @bottom_undo_fcn;       % Undo action
        cmd.InverseVarargin = {main_figure,layer.Transceivers(idx_freq),old_bot};

        uiundo(main_figure,'function',cmd);

        display_bottom(main_figure);
        set_alpha_map(main_figure);
        set_alpha_map(main_figure,'main_or_mini','mini');     
    end



    
end
