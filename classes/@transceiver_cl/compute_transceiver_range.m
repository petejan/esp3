function range = compute_transceiver_range(trans_obj,c)

t = trans_obj.Params.SampleInterval(1);
dR = double(c .* t / 2)';
samples=trans_obj.get_transceiver_samples();

range=double(samples-1)*dR*1;

end

