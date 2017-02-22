classdef raw_idx_cl
    properties
        filename
        raw_type
        nb_samples
        time_dg
        type_dg
        pos_dg%bytes from start of the file
        len_dg%
        chan_dg
    end
    
    
    methods
        function obj = curve_cl(varargin)
            p = inputParser;
            
            addParameter(p,'filename','',@ischar);
            addParameter(p,'raw_type','',@ischar);
            addParameter(p,'nb_samples',[],@isnumeric);
            addParameter(p,'time_dg',[],@isnumeric);
            addParameter(p,'type_dg',[],@isnumeric);
            addParameter(p,'pos_dg',[],@isnumeric);
            addParameter(p,'len_dg',[],@isnumeric);
            addParameter(p,'chan_dg',[],@isnumeric);
            
            parse(p,varargin{:});
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
                
            end
            
        end
        
        function nb_pings=get_nb_pings_per_channels(idx_obj)
            channels=unique(idx_obj.chan_dg(~isnan(idx_obj.chan_dg)));
            nb_transceivers=length(channels);
            nb_pings=nan(1,nb_transceivers);
            for i=1:nb_transceivers
                nb_pings(i)=nansum(idx_obj.chan_dg==channels(i));
            end
            
        end
        
        
        function nb_samples=get_nb_samples_per_channels(idx_obj)
            channels=unique(idx_obj.chan_dg(~isnan(idx_obj.chan_dg)));
            nb_transceivers=length(channels);
            nb_samples=nan(1,nb_transceivers);
            for i=1:nb_transceivers
                nb_samples(i)=nanmax(idx_obj.nb_samples(idx_obj.chan_dg==channels(i)));
            end
            
        end
        
        function nb_nmea_dg=get_nb_nmea_dg(idx_obj)
            nb_nmea_dg=nansum(strcmp(idx_obj.type_dg,'NME0'));
        end
        
        function time_dg=get_time_dg(idx_obj,type)
            time_dg=idx_obj.time_dg(strcmp(idx_obj.type_dg,type));
        end
        
        function delete(obj)
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
        
    end
end
