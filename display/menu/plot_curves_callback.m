function plot_curves_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

tags=layer.get_curves_tag();


for i=1:length(tags)
    layer.disp_curves(tags{i});
end

end