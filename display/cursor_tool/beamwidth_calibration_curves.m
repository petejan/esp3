function beamwidth_calibration_curves(src,~,main_figure)
        inter_region_create(src,main_figure,'horizontal',@beamwidth_calibration_curves_func);
end