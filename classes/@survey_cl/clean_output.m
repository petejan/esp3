function clean_output(surv_obj,varargin)

p = inputParser;

addRequired(p,'surv_obj',@(obj) isa(obj,'survey_cl'));
addParameter(p,'PathToMemmap','',@ischar);
parse(p,surv_obj,varargin{:});

nb_reg=length(surv_obj.SurvOutput.regionSum.snapshot);

to_clean={'regionSum','regionSumAbscf','regionSumVbscf','regionsIntegrated'};

for ireg=1:nb_reg
    for ifi=1:length(to_clean)
        fields=fieldnames(surv_obj.SurvOutput.(to_clean{ifi}));

        if isnan(surv_obj.SurvOutput.(to_clean{ifi}).snapshot)
            for iu=1:length(fields)
                    surv_obj.SurvOutput.(to_clean{ifi}).(fields{iu})=[];
            end
        end
        
    end
    
end



end
