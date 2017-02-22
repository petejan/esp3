classdef filter_cl
    properties
        channelID
        NoOfCoefficients
        DecimationFactor
        Coefficients
    end
    
    methods
        function delete(obj)
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
    end
end