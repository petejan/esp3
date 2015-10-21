classdef map_input_cl
    properties
        Trip
        Snapshot
        Stratum
        Transect
        Filename
        Lat
        Lon
        SliceLat
        SliceLon
        SliceAbscf
        LatLim
        LonLim
        Proj
        AbscfMax
        Rmax
        Coast
        Depth_Contour
    end
    
    
    methods
        function obj=map_input_cl(varargin)
            
            %Parse Arguments
            p = inputParser;
            addParameter(p,'Trip',@iscell);
            addParameter(p,'Snapshot',@isnumeric);
            addParameter(p,'Stratum',@iscell);
            addParameter(p,'Transect',@isnumeric);
            addParameter(p,'Filename',@iscell);
            addParameter(p,'Lat',@iscell);
            addParameter(p,'Lon',@iscell);
            addParameter(p,'SliceLat',@iscell);
            addParameter(p,'SliceLon',@iscell);
            addParameter(p,'SliceAbscf',@isnumeric);
            addParameter(p,'LatLim',@isnumeric);
            addParameter(p,'LonLim',@isnumeric);
            addParameter(p,'Proj','lambert',@ischar);
            addParameter(p,'AbscfMax',0.0017,@isnumeric);
            addParameter(p,'Rmax',17,@isnumeric);
            addParameter(p,'Coast',1,@isnumeric);
            
            parse(p,varargin{:});
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
                      
        end
        
        
         
    end
    
    methods (Static)
       obj=map_input_cl_from_layers(layers,varargin); 
       obj=map_input_cl_from_mbs(mbs,varargin); 
    end
    
end