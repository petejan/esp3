function filenames=get_files_from_surv_struct(surv_data_obj,surv_struct)

check_struct=@(struct) isempty(find(isfield(struct,{'Voyage' 'SurveyName' 'Filename' 'Comment' 'Snapshot' 'Stratum' 'Transect' 'StartTime' 'EndTime'})==0, 1));
p = inputParser;

addRequired(p,'surv_data_obj',@(obj) isa(obj,'survey_data_cl'));
addRequired(p,'surv_struct',check_struct);
parse(p,surv_data_obj,surv_struct);


% 
%  idx=find(surv_data_obj.Snapshot==surv_struct.Snapshot&...
%      surv_data_obj.Transect==surv_struct.Transect&...
%      cellfun(@(x) compare_num_or_str(surv_data_obj.Stratum,x),surv_struct.Stratum)&...
%      cellfun(@(x) compare_num_or_str(surv_data_obj.Voyage,x),surv_struct.Voyage)&...SurveyName
%      cellfun(@(x) compare_num_or_str(surv_data_obj.SurveyName,x),surv_struct.SurveyName));
 
  idx=find(surv_data_obj.Snapshot==surv_struct.Snapshot&...
     surv_data_obj.Transect==surv_struct.Transect&...
     cellfun(@(x) compare_num_or_str(surv_data_obj.Stratum,x),surv_struct.Stratum));

 filenames=surv_struct.Filename(idx);


end