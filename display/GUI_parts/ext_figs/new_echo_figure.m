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
addParameter(p,'KeyPressFcn',@do_nothing,@(x) isa(x,'function_handle'));
addParameter(p,'WindowStyle','normal',@ischar);
addParameter(p,'Visible','on',@ischar);
addParameter(p,'Tag','',@ischar);
addParameter(p,'Cmap','',@ischar);

parse(p,main_figure,varargin{:});


if ~isempty(main_figure)
    hfigs=getappdata(main_figure,'ExternalFigures');
    hfigs(~isvalid(hfigs))=[];
    idx_tag=find(strcmpi({hfigs(:).Tag},p.Results.Tag));
    if ~isempty(idx_tag)
        delete(hfigs(idx_tag));
    end
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
        'DockControls','off',...
        'CloseRequestFcn',{p.Results.CloseRequestFcn,main_figure},...
        'ButtonDownFcn',{p.Results.ButtonDownFcn,main_figure},...
        'WindowScrollWheelFcn',{p.Results.WindowScrollWheelFcn,main_figure},...
        'Visible',p.Results.Visible,...
        'KeyPressFcn',{p.Results.KeyPressFcn,main_figure});
    
else
    fig_handle=p.Results.fig_handle;
    fields_in=fieldnames(p.Results);
    fig_handle.NumberTitle='off';
    fig_handle.Color='White';
    fig_handle.DockControls='off';
    for ifi=1:length(fields_in)
        if ~any(strcmp(fields_in{ifi},p.UsingDefaults))&&isprop(fig_handle,fields_in{ifi})
            set(fig_handle,fields_in{ifi},p.Results.(fields_in{ifi}));
        end
    end
end


javaFrame = get(fig_handle,'JavaFrame');
javaFrame.setFigureIcon(javax.swing.ImageIcon(fullfile(whereisEcho(),'icons','echoanalysis.png')));
if ~isempty(main_figure)
    curr_disp=getappdata(main_figure,'Curr_disp');
    font=curr_disp.Font;
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