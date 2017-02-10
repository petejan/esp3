function [ping_new_mat,range_new_mat,data_new]=apply_line_depth(trans_obj,curr_field)

line_obj=trans_obj.OffsetLine;
if isempty(line_obj)
    ping_new_mat=[];
    range_new_mat=[];
    data_new=[];
    return;
end
sample_ori=trans_obj.Data.get_samples();

range_ori=trans_obj.Data.get_range();
dr=nanmean(diff(range_ori));

range_line=resample_data_v2(line_obj.Range,line_obj.Time,trans_obj.Data.Time);
sample_line=round(range_line/dr);
sample_line(isnan(sample_line))=1;

sample_ori_mat=bsxfun(@plus,sample_ori,sample_line);

sample_new=((sample_ori(1)+nanmin(sample_line)):(sample_ori(end)+nanmax(sample_line)))';

sample_new_mat=bsxfun(@plus,sample_new,zeros(size(sample_line)));

idx_mat=zeros(size(sample_new_mat));

for i=1:size(sample_new_mat,2)
    idx_mat(:,i)=ismember(sample_new_mat(:,i),sample_ori_mat(:,i));
end

    data_new=nan(size(sample_new_mat));
data=trans_obj.Data.get_datamat(curr_field);
if ~isempty(data)
    data_new(idx_mat==1)=data(:);
end

range_new_mat=(sample_new_mat-1)*dr;
ping_new_mat=repmat(1:size(range_new_mat,2),size(range_new_mat,1),1);




