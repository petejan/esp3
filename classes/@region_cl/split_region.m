function regions=split_region(reg_obj,idx_files)

file_ids=unique(idx_files);
regions=[];
for ifile=file_ids
    
    idx_ping_files=find(idx_files==ifile);
    idx_reg_inter=intersect(idx_ping_files,reg_obj.Idx_pings);
    
    if ~isempty(idx_reg_inter)
        
        if isempty(reg_obj.X_cont)
            reg_obj.Shape='Rectangular';
        end
        
        
        switch reg_obj.Shape
            case 'Polygon'
                ping_start=nan;
                ping_end=nan;
                nb_cont=0;
                X_cont={};
                Y_cont={};
                for ic=1:length(reg_obj.X_cont)
                    idx_in=find((reg_obj.X_cont{ic}+reg_obj.Idx_pings(1)-1)>=idx_ping_files(1)&(reg_obj.X_cont{ic}+reg_obj.Idx_pings(1)-1)<=idx_ping_files(end));
                    if ~isempty(idx_in)
                        nb_cont=nb_cont+1;
                        X_cont{nb_cont}=reg_obj.X_cont{ic}(idx_in);
                        Y_cont{nb_cont}=reg_obj.Y_cont{ic}(idx_in);
                        ping_start=nanmin(ping_start,nanmin(X_cont{nb_cont}));
                        ping_end=nanmax(ping_end,nanmax(X_cont{nb_cont}));
                    end
                end
                if nb_cont==0
                    continue;
                end
                for j=1:nb_cont
                    X_cont{j}=X_cont{j}-ping_start+1;
                end
                Idx_pings=reg_obj.Idx_pings(ping_start):reg_obj.Idx_pings(ping_end);

            case 'Rectangular'
                Idx_pings=idx_reg_inter;
                X_cont=[];
                Y_cont=[];
                
        end
        new_reg=region_cl(...
            'ID',reg_obj.ID,...
            'Name',reg_obj.Name,...
            'Tag',reg_obj.Tag,...
            'Type',reg_obj.Type,...
            'Idx_pings',Idx_pings,...
            'Idx_r',reg_obj.Idx_r,...
            'Shape',reg_obj.Shape,...
            'X_cont',X_cont,...
            'Y_cont',Y_cont,...
            'Reference',reg_obj.Reference,...
            'Cell_w',reg_obj.Cell_w,...
            'Cell_w_unit',reg_obj.Cell_w_unit,...
            'Cell_h',reg_obj.Cell_h,...
            'Cell_h_unit',reg_obj.Cell_h_unit);

        regions=[regions new_reg];
        
        
    end
    
    
    
    
end




end