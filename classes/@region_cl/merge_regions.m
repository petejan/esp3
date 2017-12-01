function regions_out=merge_regions(regions,varargin)

p = inputParser;

addRequired(p,'regions',@(obj) isa(obj,'region_cl'));
addParameter(p,'overlap_only',1,@isnumeric);

parse(p,regions,varargin{:});

reg_comp_mat=zeros(length(regions),length(regions));
disp('Merging regions');

for ireg_1=1:length(regions)
    region_1=regions(ireg_1);
    
    for ireg_2=1:length(regions)
        
        if reg_comp_mat(ireg_1,ireg_2)>0||ireg_1==ireg_2
            continue;
        end
        
        region_2=regions(ireg_2);

        u=intersect(region_2.Poly,region_1.Poly);      
        if p.Results.overlap_only>0
            if u.NumRegions==0
                continue;
            end
        end
        
        reg_comp_mat(ireg_1,ireg_2)=1;
        reg_comp_mat(ireg_2,ireg_1)=1;
    end
    
end

for ireg=1:length(regions)
    if ~strcmp(regions(ireg).Name,'')
        ireg_merge=find(reg_comp_mat(ireg,:));
        i_merge_tot=ireg_merge;
        added=1;
        while added==1
            for i_merge=ireg_merge
                j_merge=find(reg_comp_mat(i_merge,:));
                i_merge_tot=union(i_merge_tot,j_merge);
            end
            if length(i_merge_tot)>length(ireg_merge)
                ireg_merge=i_merge_tot;
            else
                added=0;
            end
        end
        
        for i=i_merge_tot
            region_1=regions(ireg);
            if ~strcmp(regions(i).Name,'')&&i~=ireg
               region_2=regions(i); 
               
               %[poly_combined,Type]=region_1.get_combined_poly(region_2,'union');
                [MaskReg,idx_r,idx_pings,Type]=region_1.get_combined_mask(region_2,'union');

               if p.Results.overlap_only>0
                   %if poly_combined.NumRegions==0
                   if nansum(MaskReg(:))==0
                       continue;
                   end
               end
                reg_comp_mat(ireg_1,ireg_2)=1;
                reg_comp_mat(ireg_2,ireg_1)=1;
               
                regions(ireg)=region_cl(...
                    'Shape','Polygon',...
                    'ID',region_1.ID,...
                    'Name',region_1.Name,...
                    'Type',Type,...
                    'Idx_r',idx_r,...
                    'Idx_pings',idx_pings,...
                    'MaskReg',MaskReg,...
                    'Reference','Surface',...
                    'Cell_w',region_1.Cell_w,...
                    'Cell_w_unit',region_1.Cell_w_unit,...
                    'Cell_h',region_1.Cell_h,...
                    'Cell_h_unit',region_1.Cell_h_unit);
                regions(i)=region_cl();
            end
        end
    end
end
regions(cellfun(@(x) strcmp(x,''),{regions(:).Name}))=[];
regions_out=regions;

end