function answer=close_dialog_fig(main_figure)

if ~isempty(main_figure)
    curr_disp=getappdata(main_figure,'Curr_disp');
    if ~isempty(curr_disp)
        font=curr_disp.Font;
    else
        font=[];
    end
else
    font=[];
end
QuestFig=new_echo_figure(main_figure,'units','pixels','position',[200 200 200 100],...
    'WindowStyle','modal','Visible','on','resize','off','tag','doyouwanttoquit');


uicontrol('Parent',QuestFig,...
    'Style','text',...
    'Position',[10 50 180 40],...
    'String','Close ESP3?','Fontsize',14);

uicontrol('Parent',QuestFig,...
    'Position',[40 20 50 25],...
    'String','Yes',...
    'Callback',@decision_callback,...
    'KeyPressFcn',@doControlKeyPress , 'Value',0);
noHandle=uicontrol('Parent',QuestFig,...
    'Position',[110 20 50 25],...
    'String','No',...
    'Callback',@decision_callback,'KeyPressFcn',@doControlKeyPress , 'Value',0);
setdefaultbutton(QuestFig, noHandle);
format_color_gui(QuestFig,font);
drawnow;

if ishghandle(QuestFig)
    % Go into uiwait if the figure handle is still valid.
    % This is mostly the case during regular use.
    c = matlab.ui.internal.dialog.DialogUtils.disableAllWindowsSafely();
    uiwait(QuestFig);
    delete(c);
end

if ishghandle(QuestFig)
    answer=get(QuestFig,'UserData');
else
    answer='';
end
delete(QuestFig);
drawnow; % Update the view to remove the closed figure (g1031998)

end
function decision_callback(obj, evd) %#ok
  set(gcbf,'UserData',get(obj,'String'));
  uiresume(gcbf);
end

function doControlKeyPress(obj, evd)
switch(evd.Key)
    case {'return'}       
        set(gcbf,'UserData',get(obj,'String'));
        uiresume(gcbf);       
    case 'escape'
        delete(gcbf)
end
end
