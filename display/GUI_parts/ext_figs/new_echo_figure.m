function fig_handle=new_echo_figure(main_figure,varargin)


p = inputParser;
addRequired(p,'main_figure',@(x) isempty(x)||ishandle(x));
addParameter(p,'fig_handle',[],@(x) isempty(x)||ishandle(x));
addParameter(p,'Name','',@ischar);
addParameter(p,'Position',[0.2 0.2 0.6 0.6],@isnumeric);
addParameter(p,'Units','normalized',@ischar);
addParameter(p,'MenuBar','figure',@ischar);
addParameter(p,'Resize','on',@ischar);
addParameter(p,'CloseRequestFcn',@close_win_echo,@(x) isa(x,'function_handle'));
addParameter(p,'WindowScrollWheelFcn',@do_nothing,@(x) isa(x,'function_handle'));
addParameter(p,'ButtonDownFcn',@do_nothing,@(x) isa(x,'function_handle'));
addParameter(p,'KeyPressFcn',@do_nothing,@(x) isa(x,'function_handle'));
addParameter(p,'WindowStyle','normal',@ischar);
addParameter(p,'Tag','',@ischar)

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
        'DockControls','off',...
        'CloseRequestFcn',{p.Results.CloseRequestFcn,main_figure},...
        'ButtonDownFcn',{p.Results.ButtonDownFcn,main_figure},...
        'WindowScrollWheelFcn',{p.Results.WindowScrollWheelFcn,main_figure},...
        'KeyPressFcn',{p.Results.KeyPressFcn,main_figure});
    
else
    fig_handle=p.Results.fig_handle;
    fields_in=fieldnames(p.Results);
    
    for ifi=1:length(fields_in)
        if ~any(strcmp(fields_in{ifi},p.UsingDefaults))&&isprop(fig_handle,fields_in{ifi})
            set(fig_handle,fields_in{ifi},p.Results.(fields_in{ifi}));
        end
    end
end


javaFrame = get(fig_handle,'JavaFrame');
javaFrame.setFigureIcon(javax.swing.ImageIcon(fullfile(whereisEcho(),'icons','echoanalysis.png')));

if ~isempty(main_figure)
    setappdata(main_figure,'ExternalFigures',[fig_handle hfigs]);
end

end

function do_nothing(~,~,~,~)
end

function close_win_echo(src,~,~,main_fig)
delete(src);
end