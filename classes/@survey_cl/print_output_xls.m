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

transectSumSheet=struct_to_sheet(trans_sum);

xlswrite(file,transectSumSheet',3);



end

function sheet=struct_to_sheet(str_obj)

str_obj_cell=struct2cell(str_obj);
str_obj_cell_rfmt=cell(length(str_obj_cell),length(str_obj_cell{1}));

trans_fields=fieldnames(str_obj);
for i=1:size(str_obj_cell,1)
    
    if ~isempty(strfind(trans_fields{i},'time'))
        str_obj_cell{i}=datestr(str_obj_cell{i},'dd/mm/yyyy HH:MM:SS');
    end
    
    if isnumeric(str_obj_cell{i})
        str_obj_cell_rfmt(i,:)=num2cell(str_obj_cell{i});
    else
        str_obj_cell_rfmt(i,:)=str_obj_cell{i};
    end
    
end
sheet=[fieldnames(str_obj) str_obj_cell_rfmt];

end
