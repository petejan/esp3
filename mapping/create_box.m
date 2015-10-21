function [box_lon,box_lat]=create_box(lon_lim,lat_lim,nb_pts)
box_lon=[linspace(lon_lim(1),lon_lim(2),nb_pts) linspace(lon_lim(2),lon_lim(2),nb_pts) linspace(lon_lim(2),lon_lim(1),1000) linspace(lon_lim(1),lon_lim(1),nb_pts)];
box_lat=[linspace(lat_lim(1),lat_lim(1),nb_pts) linspace(lat_lim(1),lat_lim(2),nb_pts) linspace(lat_lim(2),lat_lim(2),1000) linspace(lat_lim(2),lat_lim(1),nb_pts)];

end
