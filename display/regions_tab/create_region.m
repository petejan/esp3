
function create_region(src,~,main_figure)

region_tab_comp=getappdata(main_figure,'Region_tab');
modes=get(region_tab_comp.mode,'string');
mode_idx=get(region_tab_comp.mode,'value');
mode=modes{mode_idx};
shapes=get(region_tab_comp.shape_type,'string');
shape_idx=get(region_tab_comp.shape_type,'value');
shape=shapes{shape_idx};

switch shape
    case 'Polygon'
        hand_region_create(src,main_figure,@create_poly_region_func)
    otherwise  
        inter_region_create(src,main_figure,mode,@create_region_func)
end
reset_mode(0,0,main_figure);
end
