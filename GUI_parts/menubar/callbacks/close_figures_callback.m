function close_figures_callback(~,~,main_figure)

hfigs=getappdata(main_figure,'ExternalFigures');

for uuui=1:length(hfigs)
    delete(hfigs(uuui));
end

setappdata(main_figure,'ExternalFigures',hfigs);

end