
function data_ori_new=update_data_table(dbconn,data_ori,filename_cell,path_f)
data_ori_new=data_ori;

for i=1:length(filename_cell)
    [~,file_c,ext_c]=fileparts(filename_cell{i});
    data_logbook_to_up=dbconn.fetch(sprintf('select Filename,Snapshot,Stratum,Transect,Comment,StartTime,EndTime from logbook where Filename = ''%s''',[file_c ext_c]));
    
    if~isempty(data_ori_new)
        idx_mod=find(strcmpi(data_ori_new(:,2),[file_c ext_c]));
    else
        idx_mod=[];
    end
    if~isempty(idx_mod)
        data_ori_new(idx_mod,:)=[];
    end
    
    nb_lines_new=size(data_logbook_to_up,1);
    new_entry=cell(nb_lines_new,11);
    new_entry(:,1)=cell(nb_lines_new,1);
    new_entry(:,2)=data_logbook_to_up(:,1);
    new_entry(:,3)=data_logbook_to_up(:,2);
    new_entry(:,4)=data_logbook_to_up(:,3);
    new_entry(:,5)=data_logbook_to_up(:,4);
    new_entry(:,8)=data_logbook_to_up(:,5);
    new_entry(:,9)=data_logbook_to_up(:,6);
    new_entry(:,10)=data_logbook_to_up(:,7);
    new_entry(:,11)=num2cell(1:nb_lines_new);
    
    for il=1:nb_lines_new
        [path_xml,bot_file_str,reg_file_str]=create_bot_reg_xml_fname(fullfile(path_f,data_logbook_to_up{il,1}));
        new_entry{il,6}=exist(fullfile(path_xml,bot_file_str),'file')==2;
        if exist(fullfile(path_xml,reg_file_str),'file')==2
            tags = list_tags_only_regions_xml(fullfile(path_xml,reg_file_str));
            if ~isempty(tags)
                str_reg=cell2mat(cellfun(@(x) [ x ' ' ], unique(tags), 'UniformOutput', false));
                new_entry{il,7}=str_reg;
            else
                new_entry{il,7}='';
            end
        else
            new_entry{il,7}='';
        end
        new_entry{il,1}=false;
    end
    data_ori_new=[data_ori_new;new_entry];
end

[~,idx_sort]=sort(data_ori_new(:,9));
data_ori_new=data_ori_new(idx_sort,:);
data_ori_new(:,11)=num2cell(1:size(data_ori_new,1));

end
