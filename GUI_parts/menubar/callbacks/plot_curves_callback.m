function plot_curves_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
hfigs=getappdata(main_figure,'ExternalFigures');


tags=layer.get_curves_tag();

if isempty(tags)
    return;
end

for i=1:length(tags)
    new_fig(i)=layer.disp_curves(tags{i});
end


hfigs=[hfigs new_fig];
setappdata(main_figure,'ExternalFigures',hfigs);

end

