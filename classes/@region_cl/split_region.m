function [regions,file_ids]=split_region(reg_obj,idx_files,keep_uid)

file_ids=unique(idx_files);
regions(numel(file_ids))=region_cl();

if length(file_ids)==1
    regions=reg_obj;
    return;
end

unique_id=reg_obj.Unique_ID;

for ifile=file_ids
    
    idx_ping_files=find(idx_files==ifile);
    idx_reg_inter=intersect(idx_ping_files,reg_obj.Idx_pings);
    
    if ~isempty(idx_reg_inter)
        Idx_pings=idx_reg_inter;
%         Idx_pings(1) 
%         Idx_pings(end)
%         x_reg_rect=([Idx_pings(1) Idx_pings(end) Idx_pings(end) Idx_pings(1) Idx_pings(1)]);
%         y_reg_rect=([reg_obj.Idx_r(end) reg_obj.Idx_r(end) reg_obj.Idx_r(1) reg_obj.Idx_r(1) reg_obj.Idx_r(end)]);
%         poly_file=polyshape(x_reg_rect,y_reg_rect,'Simplify',false);
        if length(idx_reg_inter)<length(reg_obj.Idx_pings)
            switch reg_obj.Shape
                case 'Polygon'            
                    mask=reg_obj.get_sub_mask(1:numel(reg_obj.Idx_r),Idx_pings-reg_obj.Idx_pings(1)+1);

                    %poly=intersect(poly_file,reg_obj.Poly);
                case 'Rectangular'
                    mask=[];

                    %poly=[];
            end
            
            %poly.Vertices=round(poly.Vertices);
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
            
            if keep_uid
                new_reg.Unique_ID=unique_id;
            end
            
        else
            regions=reg_obj;
            file_ids=ifile;
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
file_ids(find(idx_rem))=[];
end