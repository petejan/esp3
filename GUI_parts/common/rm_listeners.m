function rm_listeners(main_figure)

if isappdata(main_figure,'ListenersH')
    ls=getappdata(main_figure,'ListenersH');
else
    ls=[];
end

for i=1:length(listeners)
    delete(ls(i));
end

ls=[];
    setappdata(main_figure,'ListenersH',ls);
end