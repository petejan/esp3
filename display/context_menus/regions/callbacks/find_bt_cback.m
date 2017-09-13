%% find_bt_cback.m
%
% Find Bad Transmits on selected area or region_cl
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
% * |select_plot|: TODO
% * |main_figure|: TODO
% * |ver|: TODO
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
% * 2017-13-09: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function find_bt_cback(~,~,select_plot,main_figure)

update_algos(main_figure);
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
trans_obj=layer.get_trans(curr_disp.Freq);

switch class(select_plot)
    case 'region_cl'
        idx_r=select_plot.Idx_r;
        idx_pings=select_plot.Idx_pings;
        
    otherwise
        idx_pings=round(nanmin(select_plot.XData)):round(nanmax(select_plot.XData));
        idx_r=round(nanmin(select_plot.YData)):round(nanmax(select_plot.YData));
end


data_sv=trans_obj.Data.get_subdatamat(idx_r,idx_pings);
data_sv_above=data_sv;
idx_below=bsxfun(@ge,idx_r(:),trans_obj.get_bottom_idx(idx_pings));
data_sv_above(idx_below)=nan;

sv_mean_vert=10*log10(nanmean(10.^(data_sv_above/10)));
sv_mean_vert_tot=10*log10(nanmean(10.^(data_sv/10)));


idx_bad_down=[];
idx_bad_up=[];
thr_down=[-3 -6 -6 -6] ;

thr_up=[-6 -6 -6 -6] ;

for i=1:4
    idx_bad_tmp=find_idx_bad_down(sv_mean_vert,i,thr_down(i));
    idx_bad_down=union(idx_bad_tmp,idx_bad_down);
end

sv_mean_vert_tot(idx_bad_down)=nan;

for i=1:3
    idx_bad_tmp=find_idx_bad_down(-sv_mean_vert_tot,i,thr_up(i));
    idx_bad_up=union(idx_bad_tmp,idx_bad_up);
end

 
% idx_bad_up=find(diff_sv_rl>thr_up&diff_sv_lr>thr_up);
% idx_bad_up=setdiff(idx_bad_up,[idx_bad_down idx_bad_down+1 idx_bad_down-1]);
 
idx_bad=union(idx_bad_up,idx_bad_down);

old_bot=trans_obj.Bottom;
%trans_obj.addBadSector(idx_pings,1);
trans_obj.addBadSector(idx_bad+idx_pings(1)-1,0);

sv_mean_vert_bad_down=nan(size(sv_mean_vert));
sv_mean_vert_bad_down(idx_bad_down)=sv_mean_vert(idx_bad_down);

sv_mean_vert_bad_up=nan(size(sv_mean_vert));
sv_mean_vert_bad_up(idx_bad_up)=sv_mean_vert_tot(idx_bad_up);

% 
% h_fig=new_echo_figure(main_figure,'Name','Bad Transmits test','Tag','temp_badt');
% ax=axes(h_fig,'nextplot','add');
% grid(ax,'on');
% plot(ax,sv_mean_vert,'-+');
% plot(ax,sv_mean_vert_bad_down,'or');
% 
% plot(ax,sv_mean_vert_tot,'-x');
% plot(ax,sv_mean_vert_bad_up,'ok');
% 
new_bot=trans_obj.Bottom;
curr_disp.Bot_changed_flag=1;

setappdata(main_figure,'Curr_disp',curr_disp);
setappdata(main_figure,'Layer',layer);

add_undo_bottom_action(main_figure,trans_obj,old_bot,new_bot);

display_bottom(main_figure);
set_alpha_map(main_figure);
update_mini_ax(main_figure,0);

end

function idx_bad=find_idx_bad_down(sv_mean_vert,order,thr_down)

diff_sv=sv_mean_vert(1+order:end)-sv_mean_vert(1:end-order);

diff_sv_rl=[nan(1,order) diff_sv];
diff_sv_lr=[-diff_sv nan(1,order)];
    
idx_bad=find((diff_sv_rl<=thr_down&diff_sv_lr<=thr_down)|...
(diff_sv_rl<=thr_down&diff_sv_lr>=-thr_down)|...
(diff_sv_rl>=-thr_down&diff_sv_lr<=thr_down));

end




