%% print_output_xls.m
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
% * |surv_obj|: TODO: write description and info on variable
% * |file|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-24: header (Alex Schimel)
% * 2017-03-24: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function print_output_xls(surv_obj,file)

if exist(file,'file')>0
    delete(file);
end
warning('off','MATLAB:xlswrite:AddSheet');
infos=surv_obj.SurvInput.Infos;
info_sheet=[fieldnames(infos) struct2cell(infos)];
options=surv_obj.SurvInput.Options.struct();
info_sheet=[info_sheet;[fieldnames(options) struct2cell(options)]];
xlswrite(file,info_sheet,1);

strat_sum=surv_obj.SurvOutput.stratumSum;

stratumSumSheet=struct_to_sheet(strat_sum);

xlswrite(file,stratumSumSheet',2);

trans_sum=surv_obj.SurvOutput.transectSum;
trans_sum_tracks=surv_obj.SurvOutput.transectSumTracks;
trans_sum.nb_tracks=trans_sum_tracks.nb_tracks;
trans_sum.nb_st=trans_sum_tracks.nb_st;

transectSumSheet=struct_to_sheet(trans_sum);


xlswrite(file,transectSumSheet',3);


slice_trans_sum=surv_obj.SurvOutput.slicedTransectSum;

row_start=1;
for i=1:numel(slice_trans_sum.snapshot)
    [sheet_info,sheet_tot]=sliced_struct_to_sheet(slice_trans_sum,i);
    rangeStr = sprintf( 'A%d', row_start );
    xlswrite(file,sheet_info,4,rangeStr);
    row_start=row_start+size(sheet_info,1);
    
    if~isempty(sheet_tot)
        rangeStr = sprintf( 'A%d', row_start );
        xlswrite(file,sheet_tot,4,rangeStr);
        row_start=row_start+size(sheet_tot,1);
    end
    row_start=row_start+1;
end



end

function [sheet_info,sheet_tot]=sliced_struct_to_sheet(str_obj,idx)
fields=fieldnames(str_obj);

idx_info=[];
idx_tot=[];
i_info=0;
i_tot=0;

for i=1:numel(fields)
    if iscell(str_obj.(fields{i}))
        curr_f=str_obj.(fields{i}){idx};
    else
        curr_f=str_obj.(fields{i})(idx);
    end
    
    if numel(curr_f)==1||ischar(curr_f)
        
        i_info=i_info+1;
        idx_info=union(idx_info,i);
        str_obj_cell_info_rfmt{i_info}=curr_f;
        
        if ~isempty(strfind(fields{i},'time'))
            str_obj_cell_info_rfmt{i_info}=datestr(curr_f,'dd/mm/yyyy HH:MM:SS');
        end
        
    else
        i_tot=i_tot+1;
        idx_tot=union(idx_tot,i);
        
        if ~isempty(strfind(fields{i},'time'))
            curr_f=cellfun(@(x) datestr(x,'dd/mm/yyyy HH:MM:SS'),num2cell(curr_f),'UniformOutput',0);
        end
        
        if isnumeric(curr_f)
            str_obj_cell_tot_rfmt(i_tot,:)=num2cell(curr_f);
        else
            str_obj_cell_tot_rfmt(i_tot,:)=curr_f;
        end
    end
end

sheet_info=[fields(idx_info) str_obj_cell_info_rfmt'];
if ~isempty(idx_tot)
    sheet_tot=[fields(idx_tot) str_obj_cell_tot_rfmt];
else
    sheet_tot=[];
end
end


