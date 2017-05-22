function fig_handle=new_echo_figure(main_figure,varargin)


p = inputParser;
addRequired(p,'main_figure',@(x) isempty(x)||ishandle(x));
addParameter(p,'fig_handle',[],@(x) isempty(x)||ishandle(x));
addParameter(p,'Name','',@ischar);
addParameter(p,'Position',[0.2 0.2 0.6 0.6],@isnumeric);
addParameter(p,'Units','normalized',@ischar);
addParameter(p,'MenuBar','none',@ischar);
addParameter(p,'Toolbar','none',@ischar);
addParameter(p,'Resize','on',@ischar);
addParameter(p,'CloseRequestFcn',@close_win_echo,@(x) isa(x,'function_handle'));
addParameter(p,'WindowScrollWheelFcn',@do_nothing,@(x) isa(x,'function_handle'));
addParameter(p,'ButtonDownFcn',@do_nothing,@(x) isa(x,'function_handle'));
addParameter(p,'WindowKeyPressFcn',@do_nothing,@(x) isa(x,'function_handle'));
addParameter(p,'WindowStyle','normal',@ischar);
addParameter(p,'Group','ESP3',@ischar);
addParameter(p,'Visible','on',@ischar);
addParameter(p,'Tag','',@ischar);
addParameter(p,'Cmap','',@ischar);
addParameter(p,'Keep_old',0,@isnumeric);
parse(p,main_figure,varargin{:});

if p.Results.Keep_old==0
    hfigs=clean_echo_figures(main_figure,'Tag',p.Results.Tag);
else
     hfigs=getappdata(main_figure,'ExternalFigures');
end
     
    

if isempty(p.Results.fig_handle)
    fig_handle=figure('Units',p.Results.Units,...
        'Position',p.Results.Position,...
        'Color','White',...
        'Tag',p.Results.Tag,...
        'WindowStyle',p.Results.WindowStyle,...
        'Name',p.Results.Name,...
        'NumberTitle','off',...
        'Resize',p.Results.Resize,...
        'MenuBar',p.Results.MenuBar,...
        'ToolBar',p.Results.Toolbar,...
        'CloseRequestFcn',{p.Results.CloseRequestFcn,main_figure},...
        'ButtonDownFcn',{p.Results.ButtonDownFcn,main_figure},...
        'WindowScrollWheelFcn',{p.Results.WindowScrollWheelFcn,main_figure},...
        'Visible',p.Results.Visible,...
        'WindowKeyPressFcn',{p.Results.WindowKeyPressFcn,main_figure});
    
else
    fig_handle=p.Results.fig_handle;
    fields_in=fieldnames(p.Results);
    fig_handle.NumberTitle='off';
    fig_handle.Color='White';
    for ifi=1:length(fields_in)
        if ~any(strcmp(fields_in{ifi},p.UsingDefaults))&&isprop(fig_handle,fields_in{ifi})
            set(fig_handle,fields_in{ifi},p.Results.(fields_in{ifi}));
        end
    end
end

    if ~isdeployed()
       set(fig_handle,'MenuBar','figure');
       set(fig_handle,'Toolbar','figure');
    end

javaFrame = get(fig_handle,'JavaFrame');
javaFrame.setFigureIcon(javax.swing.ImageIcon(fullfile(whereisEcho(),'icons','echoanalysis.png')));
javaFrame.fHG2Client.setClientDockable(true);
set(javaFrame,'GroupName',p.Results.Group);

   

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
format_color_gui(fig_handle,font);

if ~isempty(main_figure)
    setappdata(main_figure,'ExternalFigures',[fig_handle hfigs]);
end


end

function do_nothing(~,~,~,~)
end

function close_win_echo(src,~,~,main_figure)
uiresume(src);
% if ~isempty(main_figure)
%     ext_fig=getappdata(main_figure,'ExternalFigures');
%     idx_src=find(src==ext_fig);
%     if ~isempty(idx_src)
%         ext_fig(idx_src)=[];
%         setappdata(main_figure,'ExternalFigures',ext_fig);
%     end
% end


delete(src);
end