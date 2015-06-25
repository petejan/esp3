function TS_calibration_curves(src,~,main_figure)
        inter_region_create(src,main_figure,'horizontal',@TS_calibration_curves_func);
end