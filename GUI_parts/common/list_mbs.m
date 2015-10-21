function mbs_str=list_mbs(mbs_vec)
    mbs_str=cell(1,length(mbs_vec));

    for ii=1:length(mbs_vec)
        mbs_str{ii}=sprintf('%s_%s',mbs_vec(ii).Header.title,mbs_vec(ii).Header.voyage);
    end

end