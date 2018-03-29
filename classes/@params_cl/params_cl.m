
classdef params_cl
    properties
        Time=0;
        BandWidth=0;
        ChannelID={''};
        ChannelMode=0;
        Frequency=0;
        FrequencyEnd=0;
        FrequencyStart=0;
        PulseForm=0;
        PulseLength=0;
        PulseLengthEff=0;
        SampleInterval=0;
        Slope=0;
        TransducerDepth=0;
        TransmitPower=0;
        Absorption=0; 
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
                        obj.(props{jj})=zeros(1,varargin{1});
                    end
                end
            end
            
        end
        
%         function param_obj
%               props=properties(param_obj);
%               idx_nan=(param_obj.PulseLength==0);
%               for jj=1:length(props)
%                         param_obj.(props{jj})(idx_nan)=[];
%               end
%         end
        
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
                params_out.(props{jj})=[param_start.(props{jj})(:)' param_end.(props{jj})(:)'];
            end
            
        end
        function param_str=param2str(param_obj,idx_ping)
            
            fields={'BandWidth',...
                'ChannelMode',...
                'Frequency',...
                'FrequencyEnd',...
                'FrequencyStart',...
                'PulseForm',...
                'PulseLength',...
                'PulseLengthEff',...
                'SampleInterval',...
                'Slope',...
                'TransducerDepth',...
                'TransmitPower',...
                'Absorption'};
            
            
            fields_name={'BandWidth',...
                'ChannelMode',...
                'Frequency',...
                'FrequencyEnd',...
                'FrequencyStart',...
                'PulseForm',...
                'PulseLength',...
                'PulseLengthEff',...
                'SampleInterval',...
                'Slope',...
                'TransducerDepth',...
                'TransmitPower',...
                'Absorption'};
            
            fields_fmt={'%.0f Hz',...
                '%d',...
                '%d Hz',...
                '%d Hz',...
                '%d Hz',...
                '%d',...
                '%.6f s',...
                '%.6f s',...
                '%.6f s',...
                '%.6f',....
                '%.2f m',...
                '%.0f W',...
                '%.4f dB/m'};
            
            
            param_str =sprintf('<html><ul>Parameters for ping %d:',idx_ping);
            
            for ifi=1:length(fields)
                
                if length(param_obj.(fields{ifi}))<=idx_ping
                    idx_ping=1;
                end
                
                if iscell(param_obj.(fields{ifi}))
                    str_temp=sprintf(fields_fmt{ifi},param_obj.(fields{ifi}){idx_ping});
                else
                    if isnan(param_obj.(fields{ifi})(idx_ping))
                        continue;
                    end
                    str_temp=sprintf(fields_fmt{ifi},param_obj.(fields{ifi})(idx_ping));
                end
                
                param_str = [param_str '<li><i>' fields_name{ifi} ': </i>' str_temp '</li>'];
            end
            param_str = [param_str '</ul></html>'];
        end
        
        
           
        function params_section=get_params_idx_section(params_obj,idx)
            params_section=params_obj;
            
            props=properties(params_obj);
            
            for iprop=1:length(props)
                try
                    params_section.(props{iprop})= params_obj.(props{iprop})(idx);
                catch
                     params_section.(props{iprop})= params_obj.(props{iprop});
                end
                  
            end

        end
        
        
        
        
        function delete(obj)
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
    end
    
end




