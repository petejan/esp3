function mask=mask_from_st(trans_obj)

st=trans_obj.ST;
nb_pings=length(trans_obj.get_transceiver_pings());
nb_samples=length(trans_obj.get_transceiver_range());
mask=nan(nb_samples,nb_pings);
[~,Np]=trans_obj.get_pulse_length(1);
if ~isempty(st)
    for i=1:length(st.TS_comp)
        i_ping=find(st.Ping_number(i)==trans_obj.get_transceiver_pings());
        i_pings=nanmax(i_ping-1,1):nanmin(i_ping+1,nb_pings);
        idx_r=nanmax(st.idx_r(i)-ceil(Np),1):nanmin(st.idx_r(i)+ceil(2*Np),nb_samples);
        mask(idx_r,i_pings)=1;
    end
end

mask=~isnan(mask);

end