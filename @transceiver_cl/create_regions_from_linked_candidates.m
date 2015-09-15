function create_regions_from_linked_candidates(trans,linked_candidates,w_unit,h_unit,cell_w,cell_h)

Sv=trans.Data.get_datamat('svdenoised');
if isempty(Sv)
    Sv=trans.Data.get_datamat('sv');
end

for j=1:nanmax(linked_candidates(:))
    curr_reg=(linked_candidates==j);
    curr_Sv=Sv;
    curr_Sv(~curr_reg)=nan;
    [J,I]=find(curr_reg);
    if ~isempty(J)

        ping_ori=nanmax(nanmin(I)-1,1);
        sample_ori=nanmax(nanmin(J)-1,1);
        Bbox_w=(nanmax(I)-nanmin(I));
        Bbox_h=(nanmax(J)-nanmin(J));
        
        idx_pings=ping_ori:ping_ori+Bbox_w-1;
        idx_r=sample_ori:sample_ori+Bbox_h-1;
        
        reg_temp=region_cl(...
            'ID',new_id(trans,'School'),...
            'Name','School',...
            'Type','Data',...
            'Idx_pings',idx_pings,...
            'Idx_r',idx_r,...
            'Shape','Polygon',...
            'Sv_reg',curr_Sv(idx_r,idx_pings),...
            'Reference','Surface',...
            'Cell_w',cell_w,...
            'Cell_w_unit',w_unit,...
            'Cell_h',cell_h,...
            'Cell_h_unit',h_unit,...
            'Output',[]);

        trans.add_region(reg_temp);
        
    end
end