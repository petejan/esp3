function idx=find_mbs(mbs_vec,mbs_id)
idx=[];
for i=1:length(mbs_vec)
    if strcmpi(mbs_vec(i).Header.MbsId,mbs_id)
        idx=i;
    end
end

end