function set_axes_position_callback(src,~,main_figure)
state=get(src,'checked');

switch state
  case 'on'
        set(src,'checked','off');
    case 'off'
        set(src,'checked','on');
end

set_axes_position(main_figure);

end