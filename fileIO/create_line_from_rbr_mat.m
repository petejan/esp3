function obj=create_line_from_rbr_mat(filename)

    load(filename);
    %The sample times in the RBR file are such that if you go
    %datestr(RBR.sampletimes) the day and the month are switched around
    %So to put them back the right way:
    [Y,M,D,H,MN,S] = datevec(RBR.sampletimes);
    timestamp = datenum(Y,D,M,H-12,MN,S);
    depth = RBR.data(:,4);
    obj=line_cl('Tag','Imported from RBR','Range',depth,'Time',timestamp,'File_origin',filename,'UTC_diff',-12);
end