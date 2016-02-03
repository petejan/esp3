function clear_curves_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

layer.clear_curves();

end