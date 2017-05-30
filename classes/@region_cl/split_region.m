function regions=split_region(reg_obj,idx_files)

file_ids=unique(idx_files);
regions(numel(file_ids))=region_cl();

if length(file_ids)==1
    regions=reg_obj;
    return;
end

for ifile=file_ids
    
    idx_ping_files=find(idx_files==ifile);
    idx_reg_inter=intersect(idx_ping_files,reg_obj.Idx_pings);
    
    if ~isempty(idx_reg_inter)
        Idx_pings=idx_reg_inter;
        if isempty(reg_obj.X_cont)
            reg_obj.Shape='Rectangular';
        end
        
        if length(idx_reg_inter)<length(reg_obj.Idx_pings)
            switch reg_obj.Shape
                case 'Polygon'
                    mask=reg_obj.MaskReg(:,Idx_pings-reg_obj.Idx_pings(1)+1);
                case 'Rectangular'
                    mask=[];
            end
            new_reg=region_cl(...
                'ID',reg_obj.ID,...
                'Name',reg_obj.Name,...
                'Tag',reg_obj.Tag,...
                'Type',reg_obj.Type,...
                'Idx_pings',Idx_pings,...
                'Idx_r',reg_obj.Idx_r,...
                'Shape',reg_obj.Shape,...
                'MaskReg',mask,...
                'Reference',reg_obj.Reference,...
                'Cell_w',reg_obj.Cell_w,...
                'Cell_w_unit',reg_obj.Cell_w_unit,...
                'Cell_h',reg_obj.Cell_h,...
                'Cell_h_unit',reg_obj.Cell_h_unit);
        else
            regions=reg_obj;
            return;
        end
        
        regions(ifile)=new_reg;
        
    end
    
 
end

idx_rem=zeros(1,numel(regions));
for i=1:numel(regions)
    idx_rem(i)=isempty(regions(i).Idx_r)|isempty(regions(i).Idx_pings);
end

regions(find(idx_rem))=[];

end