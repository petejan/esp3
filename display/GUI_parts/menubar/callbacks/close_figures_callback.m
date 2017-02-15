function close_figures_callback(~,~,main_figure)

hfigs=getappdata(main_figure,'ExternalFigures');

for uuui=1:length(hfigs)
    if isvalid(hfigs(uuui))
    close(hfigs(uuui));
    end
end

setappdata(main_figure,'ExternalFigures',[]);

end