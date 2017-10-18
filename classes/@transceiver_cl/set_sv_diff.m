function set_sv_diff(trans_obj,diff_output,freq)

if ~isempty(diff_output)
    dataMat=ones(numel(trans_obj.Range),numel(trans_obj.Time))*(-999);
    Sv_diff=pow2db_perso(diff_output.Sv_mean_lin);
    for i=1:size(diff_output.Sample_E,1)
        for j=1:size(diff_output.Sample_E,2)
            if ~isnan(diff_output.Sample_S(i,j))&&diff_output.Ping_S(j)
                dataMat(diff_output.Sample_S(i,j):diff_output.Sample_E(i,j),...
                    diff_output.Ping_S(j):diff_output.Ping_E(j))=Sv_diff(i,j);
            end
        end
    end
    trans_obj.Data.replace_sub_data(sprintf('Sv%.0fkHz',freq/1e3),dataMat);
end

end