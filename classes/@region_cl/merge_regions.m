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
        
        if region_1.Cell_w~=region_2.Cell_w||region_1.Cell_h~=region_2.Cell_h||...
                ~strcmp(region_1.Cell_w_unit,region_2.Cell_w_unit)||~strcmp(region_1.Cell_h_unit,region_2.Cell_h_unit)||...
                ~strcmp(region_1.Reference,region_2.Reference)
            continue;
        end
        
        if p.Results.overlap_only>0
            
            x_reg_rect_1=([region_1.Idx_pings(1) region_1.Idx_pings(end) region_1.Idx_pings(end) region_1.Idx_pings(1) region_1.Idx_pings(1)]);
            y_reg_rect_1=([region_1.Idx_r(1) region_1.Idx_r(1) region_1.Idx_r(end) region_1.Idx_r(end) region_1.Idx_r(1)]);
            
            x_reg_rect_2=([region_2.Idx_pings(1) region_2.Idx_pings(end) region_2.Idx_pings(end) region_2.Idx_pings(1) region_2.Idx_pings(1)]);
            y_reg_rect_2=([region_2.Idx_r(1) region_2.Idx_r(1) region_2.Idx_r(end) region_2.Idx_r(end) region_2.Idx_r(1)]);
            
            if nansum(inpolygon(x_reg_rect_2,y_reg_rect_2,x_reg_rect_1,y_reg_rect_1))==0&&nansum(inpolygon(x_reg_rect_1,y_reg_rect_1,x_reg_rect_2,y_reg_rect_2))==0
                continue;
            end
            
        end
        
        idx_pings=nanmin([region_1.Idx_pings(1) region_2.Idx_pings(1)]):nanmax([region_1.Idx_pings(end) region_2.Idx_pings(end)]);
        idx_r=(nanmin([region_1.Idx_r(1) region_2.Idx_r(1)]):nanmax([region_1.Idx_r(end) region_2.Idx_r(end)]))';
        
        MaskReg_1_tot=zeros(length(idx_r),length(idx_pings));
        MaskReg_2_tot=zeros(length(idx_r),length(idx_pings));
        
        [~,~,idx_pings_old_1]=intersect(region_1.Idx_pings,idx_pings);
        [~,~,idx_r_old_1]=intersect(region_1.Idx_r,idx_r);
        [~,~,idx_pings_old_2]=intersect(region_2.Idx_pings,idx_pings);
        [~,~,idx_r_old_2]=intersect(region_2.Idx_r,idx_r);
        
        
        switch region_1.Shape
            case 'Polygon'
                MaskReg_1=region_1.MaskReg;
            otherwise
                MaskReg_1=ones(length(region_1.Idx_r),length(region_1.Idx_pings));
        end
        
        switch region_2.Shape
            case 'Polygon'
                MaskReg_2=region_2.MaskReg;
            otherwise
                MaskReg_2=ones(length(region_2.Idx_r),length(region_2.Idx_pings));
        end
        
        MaskReg_1_tot(idx_r_old_1,idx_pings_old_1)=MaskReg_1;
        MaskReg_2_tot(idx_r_old_2,idx_pings_old_2)=MaskReg_2;
        Mask_common=MaskReg_1_tot&MaskReg_2_tot;
        
        
        if p.Results.overlap_only>0
            if nansum(Mask_common(:))==0
                continue;
            end
        end
        
        reg_comp_mat(ireg_1,ireg_2)=1;
        reg_comp_mat(ireg_2,ireg_1)=1;
        
        %         MaskReg=MaskReg_1_tot|MaskReg_2_tot;
        %
        %         idx_merged=[idx_merged ireg_2];
        %
        %         region_1=region_cl(...
        %             'ID',region_1.ID,...
        %             'Name',region_1.Name,...
        %             'Type',region_1.Type,...
        %             'Idx_pings',idx_pings,...
        %             'Idx_r',idx_r,...
        %             'Shape','Polygon',...
        %             'MaskReg',MaskReg,...
        %             'Reference','Surface',...
        %             'Cell_w',region_1.Cell_w,...
        %             'Cell_w_unit',region_1.Cell_w_unit,...
        %             'Cell_h',region_1.Cell_h,...
        %             'Cell_h_unit',region_1.Cell_h_unit);
    end
    %     regions(idx_merged)=[];
    %    regions_out=[regions_out region_1];
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
                idx_pings=nanmin([region_1.Idx_pings(1) region_2.Idx_pings(1)]):nanmax([region_1.Idx_pings(end) region_2.Idx_pings(end)]);
                idx_r=(nanmin([region_1.Idx_r(1) region_2.Idx_r(1)]):nanmax([region_1.Idx_r(end) region_2.Idx_r(end)]))';
                
                MaskReg_1_tot=zeros(length(idx_r),length(idx_pings));
                MaskReg_2_tot=zeros(length(idx_r),length(idx_pings));
                
                [~,~,idx_pings_old_1]=intersect(region_1.Idx_pings,idx_pings);
                [~,~,idx_r_old_1]=intersect(region_1.Idx_r,idx_r);
                [~,~,idx_pings_old_2]=intersect(region_2.Idx_pings,idx_pings);
                [~,~,idx_r_old_2]=intersect(region_2.Idx_r,idx_r);
                
                
                switch region_1.Shape
                    case 'Polygon'
                        MaskReg_1=region_1.MaskReg;
                    otherwise
                        MaskReg_1=ones(length(region_1.Idx_r),length(region_1.Idx_pings));
                end
                
                switch region_2.Shape
                    case 'Polygon'
                        MaskReg_2=region_2.MaskReg;
                    otherwise
                        MaskReg_2=ones(length(region_2.Idx_r),length(region_2.Idx_pings));
                end
                
                MaskReg_1_tot(idx_r_old_1,idx_pings_old_1)=MaskReg_1;
                MaskReg_2_tot(idx_r_old_2,idx_pings_old_2)=MaskReg_2;
                Mask_common=MaskReg_1_tot&MaskReg_2_tot;
                
                if p.Results.overlap_only>0
                    if nansum(Mask_common(:))==0
                        continue;
                    end
                end
                
                reg_comp_mat(ireg_1,ireg_2)=1;
                reg_comp_mat(ireg_2,ireg_1)=1;
                
                 MaskReg_1_tot(idx_r_old_1,idx_pings_old_1)=MaskReg_1;
                 MaskReg_2_tot(idx_r_old_2,idx_pings_old_2)=MaskReg_2;

                switch region_1.Type
                    case 'Data'
                        switch region_2.Type
                            case 'Data'
                                 MaskReg=MaskReg_1_tot|MaskReg_2_tot;
                            otherwise
                                 MaskReg=MaskReg_1_tot&~MaskReg_2_tot;
                        end
                       Type=region_1.Type;
                    otherwise
                         switch region_2.Type
                            case 'Data'
                                 MaskReg=MaskReg_2_tot&~MaskReg_1_tot;
                                 Type=region_2.Type;
                            otherwise
                                 MaskReg=MaskReg_1_tot|MaskReg_2_tot;
                                 Type=region_1.Type;
                        end
                     
                end
                
                              
                regions(ireg)=region_cl(...
                    'ID',region_1.ID,...
                    'Name',region_1.Name,...
                    'Type',Type,...
                    'Idx_pings',idx_pings,...
                    'Idx_r',idx_r,...
                    'Shape','Polygon',...
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