function set_transducer_depth(trans_obj,depth,time_d)

if~isempty(time_d)
    depth_corr=resample_data_v2(depth,time_d,trans_obj.Time,curr_dist,dist_corr);
    depth_corr(isnan(depth_corr))=0;
end

trans_obj.Params.TransducerDepth=depth_corr;

end