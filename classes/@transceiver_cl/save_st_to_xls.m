function save_st_to_xls(trans_obj,file)

if exist(file,'file')>0
    delete(file);
end

st=trans_obj.ST;
if isempty(st)
    return;
end


algo_obj=get_algo_per_name(trans_obj,'SingleTarget');


algo_sheet=[fieldnames(algo_obj.Varargin) struct2cell( algo_obj.Varargin)];

st_sheet=struct_to_sheet(st);

xlswrite(file,algo_sheet,1);
xlswrite(file,st_sheet',2);