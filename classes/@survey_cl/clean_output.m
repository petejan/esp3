function clean_output(surv_obj,varargin)

p = inputParser;

addRequired(p,'surv_obj',@(obj) isa(obj,'survey_cl'));
addParameter(p,'PathToMemmap','',@ischar);
parse(p,surv_obj,varargin{:});

reg_to_clean={'regionSum','regionSumAbscf','regionSumVbscf','regionsIntegrated'};

for ifi=1:length(reg_to_clean)
    
    fields=fieldnames(surv_obj.SurvOutput.(reg_to_clean{ifi}));
    iregnan=isnan(surv_obj.SurvOutput.(reg_to_clean{ifi}).snapshot);
    for iu=1:length(fields)
        surv_obj.SurvOutput.(reg_to_clean{ifi}).(fields{iu})(iregnan)=[];
    end
    
end

strat_to_clean={'stratumSum'};

for ifi=1:length(strat_to_clean)
    
    fields=fieldnames(surv_obj.SurvOutput.(strat_to_clean{ifi}));
    istratnan=isnan(surv_obj.SurvOutput.(strat_to_clean{ifi}).snapshot);
    for iu=1:length(fields)
        surv_obj.SurvOutput.(strat_to_clean{ifi}).(fields{iu})(istratnan)=[];
    end
    
end


trans_to_clean={'transectSum','transectSumTracks','slicedTransectSum'};

for ifi=1:length(trans_to_clean)
    
    fields=fieldnames(surv_obj.SurvOutput.(trans_to_clean{ifi}));
    itrans_nan=isnan(surv_obj.SurvOutput.(trans_to_clean{ifi}).snapshot);
    for iu=1:length(fields)
        surv_obj.SurvOutput.(trans_to_clean{ifi}).(fields{iu})(itrans_nan)=[];
    end
    
end

end
