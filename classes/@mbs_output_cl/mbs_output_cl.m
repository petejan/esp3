classdef mbs_output_cl
    properties
        regionSum
        regionSumAbscf
        regionSumVbscf
        stratumSum
        transectSum
        slicedTransectSum
    end
    
    
    methods
        function obj=mbs_output_cl(varargin)
            
            obj.regionSum.Header = {'snapshot' 'stratum' 'transect' 'file' 'region_id' 'ref' 'slice_size' 'good_pings' 'start_d' 'mean_d' 'finish_d' 'av_speed' 'vbscf' 'abscf'};
            obj.regionSumAbscf.Header = {'snapshot' 'stratum' 'transect' 'file' 'region_id' 'num_v_slices' 'transmit_start' 'latitude' 'longitude' 'column_abscf'};
            obj.regionSumVbscf.Header = {'snapshot' 'stratum' 'transect' 'file' 'region_id' 'num_h_slices' 'num_v_slices' 'region_vbscf' 'vbscf_values'};
            obj.stratumSum.Header = {'snapshot' 'stratum' 'no_transects' 'abscf_mean' 'abscf_sd' 'abscf_wmean' 'abscf_var'};
            obj.transectSum.Header = {'snapshot' 'stratum' 'transect' 'dist' 'vbscf' 'abscf' 'mean_d' 'pings' 'av_speed' 'start_lat' 'start_lon' 'finish_lat' 'finish_lon'};
            obj.slicedTransectSum.Header = {'snapshot' 'stratum' 'transect' 'slice_size' 'num_slices' 'latitude' 'longitude' 'slice_abscf'};
            
            p = inputParser;
            
            addParameter(p,'regionSum',{},@iscell);
            addParameter(p,'regionSumAbscf',{},@iscell);
            addParameter(p,'regionSumVbscf',{},@iscell);
            addParameter(p,'stratumSum',{},@iscell);
            addParameter(p,'transectSum',{},@iscell);
            addParameter(p,'slicedTransectSum',{},@iscell);
            
            parse(p,varargin{:});
            
            props=fieldnames(p.Results);
            
            for i=1:length(props)
                if size(p.Results.(props{i}),2)==1
                    obj.(props{i}).Data=p.Results.(props{i});
                else
                    obj.(props{i}).Data=p.Results.(props{i})';
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
    
end