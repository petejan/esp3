function set_transducer_depth_from_line(trans_obj,line_obj)
curr_dist=trans_obj.GPSDataPing.Dist;

if nansum(curr_dist)>0
    dist_corr=curr_dist-line_obj.Dist_diff;
    time_corr=resample_data_v2(trans_obj.Time,curr_dist,dist_corr);
else
    time_corr=trans_obj.Time;
end

time_corr(isnan(time_corr))=trans_obj.Time(isnan(time_corr))+nanmean(time_corr(:)-trans_obj.Time(:));
range_line=resample_data_v2(line_obj.Range,line_obj.Time,time_corr);
range_line(isnan(range_line))=0;

trans_obj.Params.TransducerDepth=range_line;

end