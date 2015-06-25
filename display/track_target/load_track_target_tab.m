function load_track_target_tab(main_figure,algo_tab_panel)

if isappdata(main_figure,'Track_target_tab')
    track_target_tab_comp=getappdata(main_figure,'Track_target_tab');
    delete(track_target_tab_comp.track_target_tab);
    rmappdata(main_figure,'Track_target_tab');
end

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
range=layer.Transceivers(idx_freq).Data.Range;


[idx_track_target,found]=find_algo_idx(layer.Transceivers(idx_freq),'TrackTarget');

if ~found
    return;
end


algo_obj=layer.Transceivers(idx_freq).Algo(idx_track_target);
algo_track_target=algo_obj.Varargin;

track_target_tab_comp.track_target_tab=uitab(algo_tab_panel,'Title','Target Tracking');

x_ini=0.05;
y_ini=0.95;
x_sep=0.02;
y_sep=0.02;

pos=create_pos_2(6,4,x_ini,y_ini,x_sep,y_sep);



alpha_beta=uipanel(track_target_tab_comp.track_target_tab,'title','Alpha/Beta tracking','Position',[0.01 0.03 0.5 0.94],'fontsize',11,'Tag','alpha_beta');

uicontrol(alpha_beta,'Style','text','units','normalized','string','Along','pos',pos{1,2},'HorizontalAlignment','left');
uicontrol(alpha_beta,'Style','text','units','normalized','string','Across','pos',pos{1,3},'HorizontalAlignment','left');
uicontrol(alpha_beta,'Style','text','units','normalized','string','Range','pos',pos{1,4},'HorizontalAlignment','left');

uicontrol(alpha_beta,'Style','text','units','normalized','string','Alpha','pos',pos{2,1},'HorizontalAlignment','right');
track_target_tab_comp.AlphaMinAxis=uicontrol(alpha_beta,'Style','Edit','units','normalized','pos',pos{2,2},'string',num2str(algo_track_target.AlphaMinAxis),'BackgroundColor','white','callback',{@check_box,[0 1]});
track_target_tab_comp.AlphaMajAxis=uicontrol(alpha_beta,'Style','Edit','units','normalized','pos',pos{2,3},'string',num2str(algo_track_target.AlphaMajAxis),'BackgroundColor','white','callback',{@check_box,[0 1]});
track_target_tab_comp.AlphaRange=uicontrol(alpha_beta,'Style','Edit','units','normalized','pos',pos{2,4},'string',num2str(algo_track_target.AlphaRange),'BackgroundColor','white','callback',{@check_box,[0 1]});

uicontrol(alpha_beta,'Style','text','units','normalized','string','Beta','pos',pos{3,1},'HorizontalAlignment','right');
track_target_tab_comp.BetaMinAxis=uicontrol(alpha_beta,'Style','Edit','units','normalized','pos',pos{3,2},'string',num2str(algo_track_target.BetaMinAxis),'BackgroundColor','white','callback',{@check_box,[0 1]});
track_target_tab_comp.BetaMajAxis=uicontrol(alpha_beta,'Style','Edit','units','normalized','pos',pos{3,3},'string',num2str(algo_track_target.BetaMajAxis),'BackgroundColor','white','callback',{@check_box,[0 1]});
track_target_tab_comp.BetaRange=uicontrol(alpha_beta,'Style','Edit','units','normalized','pos',pos{3,4},'string',num2str(algo_track_target.BetaRange),'BackgroundColor','white','callback',{@check_box,[0 1]});

uicontrol(alpha_beta,'Style','text','units','normalized','string','Excl dist(m)','pos',pos{4,1},'HorizontalAlignment','right');
track_target_tab_comp.ExcluDistMinAxis=uicontrol(alpha_beta,'Style','Edit','units','normalized','pos',pos{4,2},'string',num2str(algo_track_target.ExcluDistMinAxis),'BackgroundColor','white','callback',{@check_box,[0 50]});
track_target_tab_comp.ExcluDistMajAxis=uicontrol(alpha_beta,'Style','Edit','units','normalized','pos',pos{4,3},'string',num2str(algo_track_target.ExcluDistMajAxis),'BackgroundColor','white','callback',{@check_box,[0 50]});
track_target_tab_comp.ExcluDistRange=uicontrol(alpha_beta,'Style','Edit','units','normalized','pos',pos{4,4},'string',num2str(algo_track_target.ExcluDistRange),'BackgroundColor','white','callback',{@check_box,[0 50]});


uicontrol(alpha_beta,'Style','text','units','normalized','string','Angle Uncert.(deg)','pos',pos{5,1},'HorizontalAlignment','right');
track_target_tab_comp.MaxStdMinorAxisAngle=uicontrol(alpha_beta,'Style','Edit','units','normalized','pos',pos{5,2},'string',num2str(algo_track_target.MaxStdMinorAxisAngle),'BackgroundColor','white','callback',{@check_box,[0 50]});
track_target_tab_comp.MaxStdMajorAxisAngle=uicontrol(alpha_beta,'Style','Edit','units','normalized','pos',pos{5,3},'string',num2str(algo_track_target.MaxStdMajorAxisAngle),'BackgroundColor','white','callback',{@check_box,[0 50]});

uicontrol(alpha_beta,'Style','text','units','normalized','string','Ping exp(%)','pos',pos{6,1},'HorizontalAlignment','right');
track_target_tab_comp.MissedPingExpMinAxis=uicontrol(alpha_beta,'Style','Edit','units','normalized','pos',pos{6,2},'string',num2str(algo_track_target.MissedPingExpMinAxis),'BackgroundColor','white','callback',{@check_box,[0 100]});
track_target_tab_comp.MissedPingExpMajAxis=uicontrol(alpha_beta,'Style','Edit','units','normalized','pos',pos{6,3},'string',num2str(algo_track_target.MissedPingExpMajAxis),'BackgroundColor','white','callback',{@check_box,[0 100]});
track_target_tab_comp.MissedPingExpRange=uicontrol(alpha_beta,'Style','Edit','units','normalized','pos',pos{6,4},'string',num2str(algo_track_target.MissedPingExpRange),'BackgroundColor','white',    'callback',{@check_box,[0 100]});

x_ini=0.05;
y_ini=0.95;
x_sep=0.02;
y_sep=0.02;

pos=create_pos_2(5,2,x_ini,y_ini,x_sep,y_sep);

weights_panel=uipanel(track_target_tab_comp.track_target_tab,'title','Weights','Position',[0.52 0.03 0.21 0.94],'fontsize',11,'Tag','exclu_dist');

uicontrol(weights_panel,'Style','text','units','normalized','string','Along','pos',pos{1,1},'HorizontalAlignment','right');
track_target_tab_comp.WeightMinAxis=uicontrol(weights_panel,'Style','Edit','units','normalized','pos',pos{1,2},'string',num2str(algo_track_target.WeightMinAxis),'BackgroundColor','white','callback',{@check_box,[0 100]});

uicontrol(weights_panel,'Style','text','units','normalized','string','Across','pos',pos{2,1},'HorizontalAlignment','right');
track_target_tab_comp.WeightMajAxis=uicontrol(weights_panel,'Style','Edit','units','normalized','pos',pos{2,2},'string',num2str(algo_track_target.WeightMajAxis),'BackgroundColor','white','callback',{@check_box,[0 100]});

uicontrol(weights_panel,'Style','text','units','normalized','string','Range','pos',pos{3,1},'HorizontalAlignment','right');
track_target_tab_comp.WeightRange=uicontrol(weights_panel,'Style','Edit','units','normalized','pos',pos{3,2},'string',num2str(algo_track_target.WeightRange),'BackgroundColor','white','callback',{@check_box,[0 100]});

uicontrol(weights_panel,'Style','text','units','normalized','string','TS','pos',pos{4,1},'HorizontalAlignment','right');
track_target_tab_comp.WeightTS=uicontrol(weights_panel,'Style','Edit','units','normalized','pos',pos{4,2},'string',num2str(algo_track_target.WeightTS),'BackgroundColor','white','callback',{@check_box,[0 100]});

uicontrol(weights_panel,'Style','text','units','normalized','string','Ping Gap','pos',pos{5,1},'HorizontalAlignment','right');
track_target_tab_comp.WeightPingGap=uicontrol(weights_panel,'Style','Edit','units','normalized','pos',pos{5,2},'string',num2str(algo_track_target.WeightPingGap),'BackgroundColor','white','callback',{@check_box,[0 100]});


accept=uipanel(track_target_tab_comp.track_target_tab,'title','Track acceptance','Position',[0.74 0.03 0.25 0.94],'fontsize',11,'Tag','accept');

uicontrol(accept,'Style','text','units','normalized','string','MinST #','pos',pos{1,1},'HorizontalAlignment','right');
track_target_tab_comp.Min_ST_Track=uicontrol(accept,'Style','Edit','units','normalized','pos',pos{1,2},'string',num2str(algo_track_target.Min_ST_Track),'BackgroundColor','white','callback',{@check_box,[0 200]});

uicontrol(accept,'Style','text','units','normalized','string','MinPings #','pos',pos{2,1},'HorizontalAlignment','right');
track_target_tab_comp.Min_Pings_Track=uicontrol(accept,'Style','Edit','units','normalized','pos',pos{2,2},'string',num2str(algo_track_target.Min_Pings_Track),'BackgroundColor','white','callback',{@check_box,[0 100]});

uicontrol(accept,'Style','text','units','normalized','string','MaxPingGap #','pos',pos{3,1},'HorizontalAlignment','right');
track_target_tab_comp.Max_Gap_Track=uicontrol(accept,'Style','Edit','units','normalized','pos',pos{3,2},'string',num2str(algo_track_target.Max_Gap_Track),'BackgroundColor','white','callback',{@check_box,[0 100]});


uicontrol(track_target_tab_comp.track_target_tab,'Style','pushbutton','String','Apply','units','normalized','pos',[0.8 0.15 0.1 0.1],'callback',{@validate,main_figure});
uicontrol(track_target_tab_comp.track_target_tab,'Style','pushbutton','String','Copy','units','normalized','pos',[0.8 0.05 0.1 0.1],'callback',{@copy_across,main_figure,'TrackTarget'});

setappdata(main_figure,'Track_target_tab',track_target_tab_comp);
end



function validate(~,~,main_figure)

update_algos(main_figure);
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
%axes_panel_comp=getappdata(main_figure,'Axes_panel');
%single_target_tab_comp=getappdata(main_figure,'Single_target_tab');
%region_tab_comp=getappdata(main_figure,'Region_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
idx_track_target=find_algo_idx(layer.Transceivers(idx_freq),'TrackTarget');


tracks=feval(layer.Transceivers(idx_freq).Algo(idx_track_target).Function,layer.Transceivers(idx_freq).ST,...
    'AlphaMajAxis',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.AlphaMajAxis,...
        'AlphaMinAxis',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.AlphaMinAxis,...
        'AlphaRange',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.AlphaRange,...
        'BetaMajAxis',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.BetaMajAxis,...
        'BetaMinAxis',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.BetaMinAxis,...
        'BetaRange',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.BetaRange,...
        'ExcluDistMajAxis',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.ExcluDistMajAxis,...
        'ExcluDistMinAxis',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.ExcluDistMinAxis,...
        'ExcluDistRange',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.ExcluDistRange,...
        'MaxStdMinorAxisAngle',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.MaxStdMinorAxisAngle,...
        'MaxStdMajorAxisAngle',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.MaxStdMajorAxisAngle,...
        'MissedPingExpMajAxis',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.MissedPingExpMajAxis,...
        'MissedPingExpMinAxis',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.MissedPingExpMinAxis,...
        'MissedPingExpRange',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.MissedPingExpRange,...
        'WeightMajAxis',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.WeightMajAxis,...
        'WeightMinAxis',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.WeightMinAxis,...
        'WeightRange',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.WeightRange,...
        'WeightTS',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.WeightTS,...
        'WeightPingGap',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.WeightPingGap,...
        'Min_ST_Track',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.Min_ST_Track,...
        'Min_Pings_Track',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.Min_Pings_Track,...
        'Max_Gap_Track',layer.Transceivers(idx_freq).Algo(idx_track_target).Varargin.Max_Gap_Track);


layer.Transceivers(idx_freq).Tracks=tracks;

setappdata(main_figure,'Layer',layer);
update_display(main_figure,0);

end


function check_box(hObject,~,min_max)
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry)||user_entry<min_max(1)||user_entry>min_max(2)
    set(hObject,'string',min_max(1));
    warndlg(['Input outside range [' num2str(min_max(1)) ' ' num2str(min_max(2)) ']'] ,'Bad Input','modal')
    uicontrol(hObject)
end
end

    
