function [snaps,strat,trans,regs]=merge_survey_input_for_integration(surv_in_obj,varargin)

p = inputParser;
addRequired(p,'surv_in_obj',@(obj) isa(obj,'survey_input_cl'));
parse(p,surv_in_obj,varargin{:});

[snap_vec,strat_vec,trans_vec,~,~,regs_cell]=list_transects(surv_in_obj);

[~,~,strat_vec_num]=unique(strat_vec);
[trans_triple,b_temp,c_temp]=unique([snap_vec;strat_vec_num';trans_vec]','rows');

snaps=(trans_triple(:,1));
strat=strat_vec(b_temp);
trans=(trans_triple(:,3));
regs=cell(1,length(snaps));

for i=1:length(trans)
    reg_temp=[regs_cell{i==c_temp}];
    idx_keep=[];
    idx_ID=find(cellfun(@(x) isfield(x,'IDs'),reg_temp));
    reg_temp_struct=[reg_temp{idx_ID}];
    if ~isempty(reg_temp_struct)
        [~,idx_tmp]=unique({reg_temp_struct.IDs});
        idx_keep=union(idx_keep,idx_ID(idx_tmp));
    end
    
    idx_name=find(cellfun(@(x) isfield(x,'name'),reg_temp));
    reg_temp_struct=[reg_temp{idx_name}];
    if ~isempty(reg_temp_struct)
        [~,idx_tmp]=unique({reg_temp_struct.name});
        idx_keep=union(idx_keep,idx_name(idx_tmp));
    end
    
    if ~isempty(idx_keep)
        regs{i}=reg_temp(idx_keep);
    end
end
end