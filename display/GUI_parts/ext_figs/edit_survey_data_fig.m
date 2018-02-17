
function survey_data_out=edit_survey_data_fig(main_fig,survey_data_obj,editable,tt)
FigPos=[200 200 240 380];

if isempty(tt)
    tt='Transect informations';
end
edit_sd_fig = new_echo_figure(main_fig,'Units','Pixels','Position',FigPos,'Resize','off',...
    'Name',tt,'WindowStyle','modal','Tag','edit_sd_fig');
set(edit_sd_fig,'KeyPressFcn',@doFigureKeyPress);


TextInfo.Units              = 'pixels'   ;
TextInfo.HorizontalAlignment= 'left'     ;
TextInfo.HandleVisibility   = 'callback' ;

StInfo=TextInfo;
StInfo.Style              = 'text'  ;

DefOffset    = 10;
BtnWidth  = 50;
BtnHeight = 20;

EdInfo=StInfo;
EdInfo.Style           = 'edit';
EdInfo.BackgroundColor = 'white';

BtnInfo=StInfo;
BtnInfo.Style               = 'pushbutton';
BtnInfo.HorizontalAlignment = 'center';
StInfo.BackgroundColor = 'white';

LstboxInfo=StInfo;
LstboxInfo.Style='popup';

types=init_trans_type();

idx_t=find(strcmpi(deblank(survey_data_obj.Type),deblank(types)));
if isempty(idx_t)
    idx_t=1;
end

uicontrol(edit_sd_fig,StInfo,'string','Survey name: ','pos',[10 320 90 20],'HorizontalAlignment','right');
survey_handle=uicontrol(edit_sd_fig,EdInfo,'pos',[100 320 100 20],'string',survey_data_obj.SurveyName,'enable',editable{1});

uicontrol(edit_sd_fig,StInfo,'string','Voyage: ','pos',[20 280 80 20],'HorizontalAlignment','right');
voy_handle=uicontrol(edit_sd_fig,EdInfo,'pos',[100 280 80 20],'string',survey_data_obj.Voyage,'enable',editable{2});

uicontrol(edit_sd_fig,StInfo,'string','Snapshot: ','pos',[20 240 80 20],'HorizontalAlignment','right');
snap_handle=uicontrol(edit_sd_fig,EdInfo,'pos',[100 240 40 20],'string',num2str(survey_data_obj.Snapshot),'callback',{@check_fmt_box,0,inf,0,'%.0f'},'enable',editable{3});

uicontrol(edit_sd_fig,StInfo,'string','Type: ','pos',[20 200 80 20],'HorizontalAlignment','right');
type_handle=uicontrol(edit_sd_fig,LstboxInfo,'pos',[100 200 100 20],'string',init_trans_type(),'value',idx_t,'enable',editable{4});

uicontrol(edit_sd_fig,StInfo,'string','Stratum: ','pos',[20 160 80 20],'HorizontalAlignment','right');
strat_handle=uicontrol(edit_sd_fig,EdInfo,'pos',[100 160 60 20],'string',survey_data_obj.Stratum,'enable',editable{5});

uicontrol(edit_sd_fig,StInfo,'string','Transect: ','pos',[20 120 80 20],'HorizontalAlignment','right');
trans_handle=uicontrol(edit_sd_fig,EdInfo,'pos',[100 120 40 20],'string',survey_data_obj.Transect,'callback',{@check_fmt_box,0,inf,0,'%.0f'},'enable',editable{6});

uicontrol(edit_sd_fig,StInfo,'string','Comment: ','pos',[20 80 80 20],'HorizontalAlignment','right');
comment_handle=uicontrol(edit_sd_fig,EdInfo,'pos',[20 40 200 40],'string',survey_data_obj.Comment,'enable',editable{7},'Max',10,'Min',1);


OKHandle=uicontrol(edit_sd_fig     ,              ...
   BtnInfo, ...
  'Position'   ,[ FigPos(3)-2*BtnWidth-2*DefOffset DefOffset BtnWidth BtnHeight ] , ...
  'KeyPressFcn',@doControlKeyPress , ...
  'String'     ,'OK', ...
  'Callback'   ,@doCallback , ...
  'Tag'        ,'OK'        , ...
  'UserData'   ,'OK'          ...
  );

CancelHandle=uicontrol(edit_sd_fig     ,              ...
  BtnInfo      , ...
  'Position'   ,[ FigPos(3)-BtnWidth-DefOffset DefOffset BtnWidth BtnHeight ]           , ...
  'KeyPressFcn',@doControlKeyPress            , ...
  'String'     ,getString(message('MATLAB:uistring:popupdialogs:Cancel'))    , ...
  'Callback'   ,@doCallback , ...
  'Tag'        ,'Cancel'    , ...
  'UserData'   ,'Cancel'       ...
  ); %#ok

setdefaultbutton(edit_sd_fig, OKHandle);
movegui(edit_sd_fig);

if ishghandle(edit_sd_fig)
    % Go into uiwait if the figure handle is still valid.
    % This is mostly the case during regular use.
    c = matlab.ui.internal.dialog.DialogUtils.disableAllWindowsSafely();
    uiwait(edit_sd_fig);
    delete(c);
end

% Check handle validity again since we may be out of uiwait because the
% figure was deleted.
if ishghandle(edit_sd_fig)
    
    if strcmp(get(edit_sd_fig,'UserData'),'OK')
        survey_data_out=survey_data_cl();
            survey_data_out.Voyage=voy_handle.String;
            survey_data_out.SurveyName=survey_handle.String;
            survey_data_out.Snapshot=snap_handle.String;
            survey_data_out.Type=type_handle.String{type_handle.Value};
            survey_data_out.Stratum=strat_handle.String;
            survey_data_out.Transect=trans_handle.String;
            survey_data_out.Comment=comment_handle.String;
    else
       survey_data_out=survey_data_cl.empty(); 
    end
    delete(edit_sd_fig);
else
    survey_data_out=survey_data_cl.empty();
end
drawnow; % Update the view to remove the closed figure (g1031998)

end

function doFigureKeyPress(obj, evd) %#ok
switch(evd.Key)
    case {'return','space'}
        set(gcbf,'UserData','OK');
        uiresume(gcbf);
    case {'escape'}
        delete(gcbf);
end
end

function doControlKeyPress(obj, evd) %#ok
switch(evd.Key)
    case {'return'}
        if ~strcmp(get(obj,'UserData'),'Cancel')
            set(gcbf,'UserData','OK');
            uiresume(gcbf);
        else
            delete(gcbf)
        end
    case 'escape'
        delete(gcbf)
end
end

function doCallback(obj, evd) %#ok
if ~strcmp(get(obj,'UserData'),'Cancel')
    set(gcbf,'UserData','OK');
    uiresume(gcbf);
else
    delete(gcbf)
end
end