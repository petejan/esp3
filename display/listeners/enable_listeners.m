function enable_listeners(main_figure)

if isappdata(main_figure,'ListenersH')
    ls=getappdata(main_figure,'ListenersH');
else
    ls=[];
end

if ~isempty(ls)
    for i=1:length(ls)
        ls(i).Enabled = true;
    end
end

setappdata(main_figure,'ListenersH',ls);

end