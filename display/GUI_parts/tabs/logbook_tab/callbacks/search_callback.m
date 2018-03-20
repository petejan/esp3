
function search_callback(~,~,surv_tab)
surv_data_table=getappdata(surv_tab,'surv_data_table');
data_ori=getappdata(surv_tab,'data_ori');
text_search=regexprep(get(surv_data_table.search_box,'string'),'[^\w'']','');

file=get(surv_data_table.file,'value');
snap=get(surv_data_table.snap,'value');
strat=get(surv_data_table.strat,'value');
trans=get(surv_data_table.trans,'value');
reg=get(surv_data_table.reg,'value');

if isempty(text_search)||(~file&&~snap&&~trans&&~strat&&~reg)
    data=data_ori;
else
    
    if snap>0
        idx_snap=cell2mat(data_ori(:,3))==str2double(text_search);
    else
        idx_snap=zeros(size(data_ori,1),1);
    end
    
    
    if trans>0
        idx_trans=cell2mat(data_ori(:,6))==str2double(text_search);
    else
        idx_trans=zeros(size(data_ori,1),1);
    end
    
    if strat>0
        idx_strat=strcmpi(data_ori(:,5),text_search);
    else
        idx_strat=zeros(size(data_ori,1),1);
    end
    
    if file>0
        files=regexprep(data_ori(:,2),'[^\w'']','');
        out_files=regexpi(files,text_search);
        idx_files=cellfun(@(x) ~isempty(x),out_files);
    else
        idx_files=zeros(size(data_ori,1),1);
    end
    
    if reg>0
        regs=regexprep(data_ori(:,8),'[^\w'']','');
        out_regs=regexpi(regs,text_search);
        idx_regs=cellfun(@(x) ~isempty(x),out_regs);
    else
        idx_regs=zeros(size(data_ori,1),1);
    end
    
    data=data_ori(idx_snap|idx_strat|idx_files|idx_trans|idx_regs,:);
    
end

set(surv_data_table.table_main,'Data',data);

end