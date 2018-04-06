function struct_out=survey_data_obj_to_ac_db_struct(survey_data_obj)

if ~iscell(survey_data_obj)
    survey_data_obj={survey_data_obj};
end

nb_trans=sum(cellfun(@numel,survey_data_obj));

struct_out.transect_description=cell(nb_trans,1);
struct_out.transect_related_activity=cell(nb_trans,1);

% struct_out.transect_northlimit=nan(nb_trans,1);
% struct_out.transect_eastlimit=nan(nb_trans,1);
% struct_out.transect_southlimit=nan(nb_trans,1);
% struct_out.transect_westlimit=nan(nb_trans,1);
% struct_out.transect_uplimit=nan(nb_trans,1);
% struct_out.transect_downlimit=nan(nb_trans,1);
% struct_out.transect_units=cell(nb_trans,1);
% struct_out.transect_zunits=cell(nb_trans,1);
% struct_out.transect_projection=cell(nb_trans,1);

struct_out.transect_name=cell(nb_trans,1);
struct_out.transect_start_time=nan(nb_trans,1);
struct_out.transect_end_time=nan(nb_trans,1);
struct_out.transect_snapshot=nan(nb_trans,1);
struct_out.transect_stratum=cell(nb_trans,1);
struct_out.transect_station=cell(nb_trans,1);
struct_out.transect_type=cell(nb_trans,1);
struct_out.transect_number=nan(nb_trans,1);
struct_out.transect_comments=cell(nb_trans,1);

itr=1;
for is=1:numel(survey_data_obj)
    for iss=1:numel(survey_data_obj{is})
        if  ~isempty(survey_data_obj{is}{iss})
            if ~(survey_data_obj{is}{iss}.Snapshot==0 && survey_data_obj{is}{iss}.Transect==0&& ...
                 strcmpi(deblank(survey_data_obj{is}{iss}.Type),'')&&strcmpi(deblank(survey_data_obj{is}{iss}.Stratum),''))
                struct_out.transect_name{itr}=survey_data_obj{is}{iss}.print_survey_data();
                struct_out.transect_station{itr}='';
                struct_out.transect_description{itr}='';
                struct_out.transect_related_activity{itr}='';
                struct_out.transect_start_time(itr)=survey_data_obj{is}{iss}.StartTime;
                struct_out.transect_end_time(itr)=survey_data_obj{is}{iss}.EndTime;
                struct_out.transect_snapshot(itr)=survey_data_obj{is}{iss}.Snapshot;
                struct_out.transect_stratum{itr}=survey_data_obj{is}{iss}.Stratum;
                struct_out.transect_type{itr}=survey_data_obj{is}{iss}.Type;
                struct_out.transect_number(itr)=survey_data_obj{is}{iss}.Transect;
                struct_out.transect_comments{itr}=survey_data_obj{is}{iss}.Comment;
                itr=itr+1;
            end
        end
    end
end


idx_rem=isnan(struct_out.transect_snapshot);
fields=fieldnames(struct_out);

for ifi=1:numel(fields)
    struct_out.(fields{ifi})(idx_rem)=[];
end

struct_out.transect_start_time=cellfun(@(x) datestr(x,'yyyy-mm-dd HH:MM:SS'),num2cell(struct_out.transect_start_time),'un',0);
struct_out.transect_end_time=cellfun(@(x) datestr(x,'yyyy-mm-dd HH:MM:SS'),num2cell(struct_out.transect_end_time),'un',0);



end