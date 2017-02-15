function [cmap,col_ax,col_lab,col_grid,col_bot]=init_cmap(cmap_name)

switch lower(cmap_name)
    case {'parula' 'jet' 'hsv' 'winter' 'autumn' 'spring' 'hot' 'cool'}
        cmap=colormap(cmap_name);
        col_ax='w';
        col_lab='k';
        col_grid=[0 0 0];
        col_bot='k'; 
    case 'esp2'
        cmap=esp2_colormap();
        col_ax='k';
        col_lab=[0.8 0.8 0.8];
        col_grid=[1 1 1];
        col_bot='y';
    case 'ek500'
        cmap=ek500_colormap();
        col_ax='w';
        col_lab='k';
        col_grid=[0 0 0];
        col_bot=[0 0.5 0];
     case 'ek60'
        cmap=ek60_colormap();
        col_ax='w';
        col_lab='k';
        col_grid=[0 0 0];
        col_bot='k'; 
end