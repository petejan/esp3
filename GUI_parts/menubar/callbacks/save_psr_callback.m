
function save_psr_callback(~,~,main_figure)
layers=getappdata(main_figure,'Layers');
for i=1:length(layers)
    layers(i).save_regs();
end
end