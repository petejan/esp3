%% create_regions_from_linked_candidates.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |trans|: TODO: write description and info on variable
% * |linked_candidates|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function id_rem=create_regions_from_linked_candidates(trans,linked_candidates,varargin)

p = inputParser;

check_w_unit=@(unit) ~isempty(strcmp(unit,{'pings','meters'}));
check_h_unit=@(unit) ~isempty(strcmp(unit,{'samples','meters'}));

addRequired(p,'trans',@(obj) isa(obj,'transceiver_cl'));
addRequired(p,'linked_candidates',@isnumeric);
addParameter(p,'w_unit','pings',check_w_unit);
addParameter(p,'h_unit','meters',check_h_unit);
addParameter(p,'cell_w',10);
addParameter(p,'cell_h',5);
addParameter(p,'ref','Surface');
addParameter(p,'bbox_only',0);


parse(p,trans,linked_candidates,varargin{:});

w_unit=p.Results.w_unit;
h_unit=p.Results.h_unit;
cell_h=p.Results.cell_h;
cell_w=p.Results.cell_w;
bbox_only=p.Results.bbox_only;
ref=p.Results.ref;


Sv=trans.Data.get_datamat('svdenoised');
if isempty(Sv)
    Sv=trans.Data.get_datamat('sv');
end
reg_schools=trans.get_region_from_name('School');

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
        
        if bbox_only==1
            reg_temp=region_cl(...
                'ID',trans.new_id(),...
                'Name','School',...
                'Type','Data',...
                'Idx_pings',idx_pings,...
                'Idx_r',idx_r,...
                'Shape','Rectangular',...
                'Reference',ref,...
                'Cell_w',cell_w,...
                'Cell_w_unit',w_unit,...
                'Cell_h',cell_h,...
                'Cell_h_unit',h_unit);
        else

            reg_temp=region_cl(...
                'ID',trans.new_id(),...
                'Name','School',...
                'Type','Data',...
                'Idx_pings',idx_pings,...
                'Idx_r',idx_r,...
                'Shape','Polygon',...
                'MaskReg',~isnan(curr_Sv(idx_r,idx_pings)),...
                'Reference',ref,...
                'Cell_w',cell_w,...
                'Cell_w_unit',w_unit,...
                'Cell_h',cell_h,...
                'Cell_h_unit',h_unit);
        end
        
        id_rem={};
        
        for i=1:length(reg_schools)
            mask_inter=reg_temp.get_mask_from_intersection(reg_schools(i));
            if any(mask_inter(:))
               id_rem=union(id_rem,reg_schools(i).Unique_ID);
               trans.rm_region_id(reg_schools(i).Unique_ID);
            end
        end     
        
        trans.add_region(reg_temp,'Split',0);
        
    end
end