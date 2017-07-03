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

trans_obj=layer.get_trans(curr_disp.Freq);

if isempty(trans_obj)
    return;
end


ST = trans_obj.ST;

if isempty(ST)
    return;
end
x0=trans_obj.Config.AngleOffsetAthwartship;
y0=trans_obj.Config.AngleOffsetAlongship;

[x1,y1]=get_ellipse_xy(trans_obj.Config.BeamWidthAthwartship,trans_obj.Config.BeamWidthAlongship,...
    x0,y0,100);
[x2,y2]=get_ellipse_xy(trans_obj.Config.BeamWidthAthwartship/2,trans_obj.Config.BeamWidthAlongship/2,...
    x0,y0,100);

switch disp_var
    case 'st'
        c = ST.TS_uncomp;
        y=ST.Angle_minor_axis;
        x=ST.Angle_major_axis;
    case 'tracks'
        tracks = trans_obj.Tracks;
        
        if isempty(tracks)
            return;
        end
        c=[];
        x=[];
        y=[];
        for k=1:length(tracks.target_id)
            idx_targets=tracks.target_id{k};
            c=[c ST.TS_comp(idx_targets)];
            y=[y ST.Angle_minor_axis(idx_targets)];
            x=[x ST.Angle_major_axis(idx_targets)];
        end
end
cax=curr_disp.getCaxField('sp');cmap_name=curr_disp.Cmap;
[cmap,~,~,~,~,~]=init_cmap(cmap_name);
hfig=new_echo_figure(main_figure,'tag','st_pos',...
    'Units','Normalized','Position',[0.1 0.2 0.3 0.4],'CloseRequestFcn',@close_pos_fig,'Name',sprintf('Single Targets position from %.0f kHz',curr_disp.Freq/1e3));

ax=axes(hfig,'outerposition',[0 0 1 1],'visible','off');
hold(ax,'on');axis(ax,'equal');
scatter(ax,x,y,10,c,'filled');
text(ax,x0+trans_obj.Config.BeamWidthAthwartship,y0,sprintf('%.1f^\\circ',x0+trans_obj.Config.BeamWidthAthwartship));
text(ax,x0-trans_obj.Config.BeamWidthAthwartship,y0,sprintf('%.1f^\\circ',x0-trans_obj.Config.BeamWidthAthwartship));
text(ax,x0,y0+trans_obj.Config.BeamWidthAlongship,sprintf('%.1f^\\circ',y0+trans_obj.Config.BeamWidthAlongship));
text(ax,x0,y0-trans_obj.Config.BeamWidthAlongship,sprintf('%.1f^\\circ',y0-trans_obj.Config.BeamWidthAlongship));
plot(ax,[x0-trans_obj.Config.BeamWidthAthwartship x0+trans_obj.Config.BeamWidthAthwartship],[y0 y0],'k');
plot(ax,[x0 x0],[y0-trans_obj.Config.BeamWidthAlongship y0+trans_obj.Config.BeamWidthAlongship],'k');
plot(ax,x2,y2,'--k');plot(ax,x1,y1,'k');

caxis(ax,cax);
colormap(ax,cmap);
colorbar(ax);
centerfig(hfig);


cax_list=addlistener(curr_disp,'Cax','PostSet',@(src,envdata)listenCaxReg(src,envdata));
cmap_list=addlistener(curr_disp,'Cmap','PostSet',@(src,envdata)listenCmapReg(src,envdata));

setappdata(main_figure,'Layer',layer);

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