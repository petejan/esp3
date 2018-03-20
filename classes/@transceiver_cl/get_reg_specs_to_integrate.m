
function reg_tot=get_reg_specs_to_integrate(trans_obj,regs_t)

reg_tot=[];
names={};
IDs={};
tags={};

for ireg=1:length(regs_t)
    if isfield(regs_t{ireg},'IDs')
        if ischar(regs_t{ireg}.IDs)
            IDs=union(IDs,strsplit(regs_t{ireg}.IDs,';'));
        else
            IDs=union(IDs,num2str(regs_t{ireg}.IDs,'%d'));
        end
    elseif isfield(regs_t{ireg},'tag')
        tags=union(tags,strsplit(regs_t{ireg}.tag,';')); 
    elseif isfield(regs_t{ireg},'name')
        names=union(names,regs_t{ireg}.name);
    else
        IDs='';
    end
end

if any(strcmp(IDs,''))>0
    idx_temp=trans_obj.find_regions_type('Data');
    reg_temp=trans_obj.get_reg_spec(idx_temp);
    reg_tot=[reg_tot reg_temp];
else
    for i_sub_reg=1:length(IDs)
        if ischar(IDs{i_sub_reg})
            out_cell=textscan(IDs{i_sub_reg},'%d(%d-%d)');
        else
            out_cell={IDs{i_sub_reg},[],[]};
        end

        idx_temp=trans_obj.find_regions_ID(abs(out_cell{1}));

        for i_temp=1:length(idx_temp)
            reg_temp=trans_obj.get_reg_spec(idx_temp(i_temp));
            if ~isempty(out_cell{2})
                reg_temp.startDepth=out_cell{2};
            end
            if ~isempty(out_cell{3})
                reg_temp.finishDepth=out_cell{3};
            elseif isempty(out_cell{3})&&~isempty(out_cell{2})
                reg_temp.startDepth=0;
                reg_temp.finishDepth=-out_cell{2};
            end
            reg_tot=[reg_tot reg_temp];
        end
    end
end


idx_temp=trans_obj.find_regions_name(names);
if ~isempty(idx_temp)
    reg_temp=trans_obj.get_reg_spec(idx_temp);
    reg_tot=[reg_tot reg_temp];
end


idx_temp=trans_obj.find_regions_tag(tags);
if ~isempty(idx_temp)
    reg_temp=trans_obj.get_reg_spec(idx_temp);
    reg_tot=[reg_tot reg_temp];
end

if ~isempty(reg_tot)
    ids={reg_tot(:).id};
    [ids_unique,ia,~]=unique(ids);
    if length(ids_unique)<length(ids)
        reg_tot=reg_tot(ia);
    end
end
end