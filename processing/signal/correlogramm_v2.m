function corr=correlogramm_v2(data,subdata)

    subdata=flipud(subdata);    
    data_auto_corr=filter2(ones(size(subdata)),(data).^2)./filter2(ones(size(subdata)),ones(size(data)));
    
    subdata_auto_corr=nansum(subdata).^2;
    
    corr=filter2(subdata,data)./sqrt(data_auto_corr*subdata_auto_corr);


end