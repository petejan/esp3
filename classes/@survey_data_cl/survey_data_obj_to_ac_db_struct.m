function struct_out=survey_data_obj_to_ac_db_struct(survey_data_obj)

if ~iscell(survey_data_obj)
    survey_data_obj={survey_data_obj};
end

nb_trans=numel(survey_data_obj);

struct_out.transect_description=cell(1,nb_trans);
struct_out.transect_related_activity=cell(1,nb_trans);

% struct_out.transect_northlimit=nan(1,nb_trans);
% struct_out.transect_eastlimit=nan(1,nb_trans);
% struct_out.transect_southlimit=nan(1,nb_trans);
% struct_out.transect_westlimit=nan(1,nb_trans);
% struct_out.transect_uplimit=nan(1,nb_trans);
% struct_out.transect_downlimit=nan(1,nb_trans);
% struct_out.transect_units=cell(1,nb_trans);
% struct_out.transect_zunits=cell(1,nb_trans);
% struct_out.transect_projection=cell(1,nb_trans);

struct_out.transect_name=cell(1,nb_trans);
struct_out.transect_start_time=nan(1,nb_trans);
struct_out.transect_end_time=nan(1,nb_trans);
struct_out.transect_snapshot=nan(1,nb_trans);
struct_out.transect_stratum=cell(1,nb_trans);
struct_out.transect_station=cell(1,nb_trans);
struct_out.transect_type=cell(1,nb_trans);
struct_out.transect_number=nan(1,nb_trans);
struct_out.transect_comments=cell(1,nb_trans);



for itr=1:nb_trans
    struct_out.transect_name{itr}=survey_data_obj{itr}.print_survey_data();
    struct_out.transect_station{itr}='';     
    struct_out.transect_start_time(itr)=st;
    struct_out.transect_end_time(itr)=et;
    struct_out.transect_snapshot(itr)=survey_data_obj{itr}.Snapshot;
    struct_out.transect_stratum{itr}=survey_data_obj{itr}.Stratum;
    struct_out.transect_type{itr}=survey_data_obj{itr}.Type;
    struct_out.transect_number(itr)=survey_data_obj{itr}.Transect;
    struct_out.transect_comments{itr}=survey_data_obj{itr}.Comment;
end

struct_out.transect_start_time=cellfun(@(x) datestr(x,'yyyy-mm-dd HH:MM:SS'),num2cell(struct_out.transect_start_time),'un',0);
struct_out.transect_end_time=cellfun(@(x) datestr(x,'yyyy-mm-dd HH:MM:SS'),num2cell(struct_out.transect_end_time),'un',0);
 




end