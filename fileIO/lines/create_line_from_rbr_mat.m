function obj=create_line_from_rbr_mat(filename)

    load(filename);

    timestamp=zeros(1,length(RBR.sampletimes));
    for i=1:length(RBR.sampletimes)
        %[Y,M,D,H,MN,S] = datevec(RBR.sampletimes{i},'dd/mm/yyyy HH:MM:SS.FFF PM');
        timestamp(i) = datenum(RBR.sampletimes{i});
    end
    fprintf('\nRBR file starts at %s and finishes at %s\n',datestr(timestamp(1)),datestr(timestamp(end)));
    depth = RBR.data(:,4);     % uncomment lines below to compensate for vessel draught
    % draught = 6;             % (m) draught of vessel (Tangaroa is 6m)
    % depth = depth - draught; % RBR depth is DBS and echogram depth is DBT
    obj=line_cl('Tag','Imported from RBR','Range',depth,'Time',timestamp,'File_origin',{filename},'UTC_diff',0);
end