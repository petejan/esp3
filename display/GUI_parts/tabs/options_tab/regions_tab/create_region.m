
function create_region(src,~,main_figure)

region_tab_comp=getappdata(main_figure,'Region_tab');
modes=get(region_tab_comp.mode,'string');
mode_idx=get(region_tab_comp.mode,'value');
mode=modes{mode_idx};
shapes=get(region_tab_comp.shape_type,'string');
shape_idx=get(region_tab_comp.shape_type,'value');
shape=shapes{shape_idx};
main_figure.Pointer = 'cross';

switch shape
    case 'Hand Drawn'
        hand_region_create(main_figure,@create_poly_region_func)
    case 'Polygon'
        poly_region_create(main_figure,@create_poly_region_func);
    otherwise
        inter_region_create(main_figure,mode,@create_region_func);
end



end
