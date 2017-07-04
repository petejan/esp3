%% plot_track_pos_callback.m
%
% Callback plotting histogram of detected single target on currently
% displayed frequency.
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
% * |main_figure|: Handle to main ESP3 window
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO
%
% *NEW FEATURES*
%
% * 2017-07-03: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function plot_st_pos_callback(~,~,main_figure,disp_var)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');
hfig=new_echo_figure(main_figure,'tag','st_pos',...
    'Units','Normalized','Position',[0.1 0.2 0.3 0.4],'CloseRequestFcn',@close_pos_fig,'Name',sprintf('Single Targets position from %.0f kHz',curr_disp.Freq/1e3));
ax=axes(hfig,'outerposition',[0 0 1 1],'visible','off');
init_st_ax(main_figure,ax);
display_st_or_track_pos(main_figure,ax,disp_var);
cax_list=addlistener(curr_disp,'Cax','PostSet',@(src,envdata)listenCaxReg(src,envdata));
cmap_list=addlistener(curr_disp,'Cmap','PostSet',@(src,envdata)listenCmapReg(src,envdata));
centerfig(hfig);

    function listenCmapReg(src,evt)
        [cmap,~,~,~,~,~]=init_cmap(evt.AffectedObject.Cmap);
        if isvalid(ax_in)
            colormap(ax,cmap);
        end
    end

    function listenCaxReg(src,evt)
        cax=evt.AffectedObject.getCaxField('sp');
        if isvalid(ax)
            caxis(ax,cax);
        end
    end


    function close_pos_fig(src,~,~)
        try
            delete(cmap_list) ;
            delete(cax_list) ;
        end
        delete(src)
    end


end