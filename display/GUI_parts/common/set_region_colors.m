
function [ac_data_col,ac_bad_data_col,in_data_col,in_bad_data_col,txt_col]=set_region_colors(curr_dispCmap)

switch curr_dispCmap
    case 'esp2'
        
        txt_col='w';
    otherwise
        txt_col='k';
end

ac_data_col=[1 0 0];
ac_bad_data_col=[240,230,140]/256;
in_data_col=[0 1 0];
in_bad_data_col=[0.5 0.5 0];

end