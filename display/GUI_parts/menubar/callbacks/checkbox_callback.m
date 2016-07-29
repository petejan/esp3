function checkbox_callback(src,~,main_figure,func)
state=get(src,'checked');

switch state
  case 'on'
        set(src,'checked','off');
    case 'off'
        set(src,'checked','on');
end

feval(func,main_figure);

end

