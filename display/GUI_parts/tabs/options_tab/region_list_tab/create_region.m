
function create_region(src,~,main_figure,shape,mode)

if check_axes_tab(main_figure)==0
    return;
end

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
