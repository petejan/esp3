function obj=create_line_from_seabird(filename)

    [~,depth,~,timestamp,~]=read_seabird(filename);
    if isempty(depth)
        obj=[];
        return; 
    end
    
    obj=line_cl('Tag','Imported from RBR','Range',depth,'Time',timestamp-12/24,'File_origin',filename,'UTC_diff',-12);
end