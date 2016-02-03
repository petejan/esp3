function obj=create_line_from_rbr_mat(filename)

    load(filename);
    %The sample times in the RBR file are strings of the format 
    %dd/mm/yyyy HH:MM:SS.FFF PM
    
    timestamp=zeros(1,length(RBR.sampletimes));
    for i=1:length(RBR.sampletimes)
        [Y,M,D,H,MN,S] = datevec(RBR.sampletimes{i},'dd/mm/yyyy HH:MM:SS.FFF PM');
        timestamp(i) = datenum(Y,M,D,H,MN,S);
    end
	depth = RBR.data(:,4)     % uncomment line below if desired
    %depth = depth - 6;       % to account for draught of Tangaroa (6m). 
    obj=line_cl('Tag','Imported from RBR','Range',depth,'Time',timestamp-12/24,'File_origin',filename,'UTC_diff',-12);
end