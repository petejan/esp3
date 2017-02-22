classdef mbs_input_cl
    properties
        snapshot=[];
        stratum={};
        transect=[];
        dfileDir={};
        crestDir={};
        channel=[];
        calRev={};
        botRev={};
        regRev={};
        rawFileName={};
        rawSubDir={};
        algo={};
        calCrest=[];
        calRaw={};
        absorption=[];
        length=[];
        reg={};
        reg_str={};
        transducer={};
        dfileNum=[];
        rawDir={};
        EsError=[];
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