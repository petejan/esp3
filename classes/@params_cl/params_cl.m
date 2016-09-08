
classdef params_cl
    properties
        Time=nan;
        BandWidth=nan;
        ChannelID={''};
        ChannelMode=nan;
        Frequency=nan;
        FrequencyEnd=nan;
        FrequencyStart=nan;
        PulseForm=nan;
        PulseLength=nan;
        PulseLengthEff=nan;
        SampleInterval=nan;
        Slope=nan;
        TransducerDepth=nan;
        TransmitPower=nan;
        Absorption=nan;
    end
    methods
        function obj=params_cl(varargin)
            if isempty(varargin)
                return;
            else
                props=properties(obj);
                for jj=1:length(props)
                   if iscell(obj.(props{jj}))
                       obj.(props{jj})=cell(1,varargin{1});
                       obj.(props{jj})(:)={''};
                   else
                        obj.(props{jj})=nan(1,varargin{1});
                   end
                end
            end
            
        end
       
    function params_out=concatenate_Params(param_1,param_2)
        if param_1.Time(1)>param_2.Time(end)
            param_start=param_2;
            param_end=param_1;
        else
            param_start=param_1;
            param_end=param_2;
        end
        
        props=properties(param_1);
        params_out=params_cl(length(param_1.Time)+length(param_2.Time));
        
        for jj=1:length(props)
            params_out.(props{jj})=[param_start.(props{jj}) param_end.(props{jj})];
        end
        
    end
        
        
    end
    
    
    
       
end

