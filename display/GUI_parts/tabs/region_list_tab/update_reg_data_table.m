%% update_reg_data_table.m
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
% * |regions|: TODO: write description and info on variable
% * |reg_table_data|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |reg_table_data_new|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * 2017-03-28: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function update_reg_data_table(regions,reg_table)


for i=1:length(regions)
    
    if~isempty(reg_table.Data)
        idx_mod=find(strcmp(regions(i).Unique_ID,reg_table.Data(:,10)));
    else
        idx_mod=[];
    end
    
    if isempty(idx_mod)
        if ~isempty(reg_table.Data)
            idx_mod=numel(reg_table.Data(:,1))+1;
        else
            idx_mod=1;
        end
    end
    
    reg_table.Data{idx_mod,1}=regions(i).Name;
    reg_table.Data{idx_mod,2}=regions(i).ID;
    reg_table.Data{idx_mod,3}=regions(i).Tag;
    reg_table.Data{idx_mod,4}=regions(i).Type;
    reg_table.Data{idx_mod,5}=regions(i).Reference;
    reg_table.Data{idx_mod,6}=regions(i).Cell_w;
    reg_table.Data{idx_mod,7}=regions(i).Cell_w_unit;
    reg_table.Data{idx_mod,8}=regions(i).Cell_h;
    reg_table.Data{idx_mod,9}=regions(i).Cell_h_unit;
    reg_table.Data{idx_mod,10}=regions(i).Unique_ID;
end

% idx_html=find(contains(reg_table.Data(:,1),'html'));
% for i=idx_html
%     idx_start=strfind(reg_table.Data{i,1},'<b>');
%     idx_end=strfind(reg_table.Data{i,1},'</b>');
%     reg_table.Data{i,1}=reg_table.Data{i,1}(idx_start+3:idx_end-1);
% end


end