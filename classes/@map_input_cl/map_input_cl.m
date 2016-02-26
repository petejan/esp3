classdef map_input_cl
    properties
        SurveyName
        Trip
        Snapshot
        Stratum
        Transect
        PathToFile
        Filename
        Lat
        Lon
        SliceLat
        SliceLon
        SliceAbscf
        Nb_ST
        Nb_Tracks
        LatLim
        LonLim
        Proj
        ValMax
        Rmax
        Coast
        Depth_Contour
    end
    
    
    methods
        function obj=map_input_cl(varargin)
            
            %Parse Arguments
            p = inputParser;
            addParameter(p,'SurveyName',@iscell);
            addParameter(p,'Trip',@iscell);
            addParameter(p,'Snapshot',@isnumeric);
            addParameter(p,'Stratum',@iscell);
            addParameter(p,'Transect',@isnumeric);
            addParameter(p,'Filename',@iscell);
            addParameter(p,'PathToFile',@iscell);
            addParameter(p,'Lat',@iscell);
            addParameter(p,'Lon',@iscell);
            addParameter(p,'SliceLat',@iscell);
            addParameter(p,'SliceLon',@iscell);
            addParameter(p,'SliceAbscf',@iscell);
            addParameter(p,'Nb_ST',@iscell);
            addParameter(p,'Nb_Tracks',@iscell);
            addParameter(p,'LatLim',@isnumeric);
            addParameter(p,'LonLim',@isnumeric);
            addParameter(p,'Proj','lambert',@ischar);
            addParameter(p,'ValMax',0.0017,@isnumeric);
            addParameter(p,'Rmax',5,@isnumeric);
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
       obj=map_input_cl_from_obj(ext_obj,varargin); 
    end
    
end