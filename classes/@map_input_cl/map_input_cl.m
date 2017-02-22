classdef map_input_cl
    properties
        SurveyName
        Voyage
        Snapshot
        Stratum
        Transect
        Filename
        Lat
        Long
        Time
        SliceLat
        SliceLong
        SliceTime_S
        SliceTime_E
        SliceAbscf
        Regions
        Nb_ST
        Nb_Tracks
        LatLim
        LongLim
        Proj
        ValMax
        Rmax
        Coast
        Depth_Contour
        PlotType
        StationCode
    end
    
    
    methods
        function obj=map_input_cl(varargin)
            
            %Parse Arguments
            p = inputParser;
            addParameter(p,'SurveyName',{},@iscell);
            addParameter(p,'Voyage',{},@iscell);
            addParameter(p,'Snapshot',[],@isnumeric);
            addParameter(p,'Stratum',{},@iscell);
            addParameter(p,'Transect',[],@isnumeric);
            addParameter(p,'Filename',{},@iscell);
            addParameter(p,'Lat',{},@iscell);
            addParameter(p,'Long',{},@iscell);
            addParameter(p,'Time',{},@iscell);
            addParameter(p,'SliceLat',{},@iscell);
            addParameter(p,'SliceLong',{},@iscell);
            addParameter(p,'SliceAbscf',{},@iscell);
            addParameter(p,'SliceTime_E',{},@iscell);
            addParameter(p,'SliceTime_S',{},@iscell);
            addParameter(p,'StationCode',{},@iscell)
            addParameter(p,'Regions',struct(),@isstruct);
            addParameter(p,'Nb_ST',{},@iscell);
            addParameter(p,'Nb_Tracks',{},@iscell);
            addParameter(p,'LatLim',[nan nan],@isnumeric);
            addParameter(p,'LongLim',[nan nan],@isnumeric);
            addParameter(p,'Proj','lambert',@ischar);
            addParameter(p,'ValMax',0.0017,@isnumeric);
            addParameter(p,'Rmax',5,@isnumeric);
            addParameter(p,'Coast',1,@isnumeric);
            addParameter(p,'Depth_Contour',0,@isnumeric);
            addParameter(p,'PlotType','log10',@ischar);
            parse(p,varargin{:});
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
                      
        end
        function delete(obj)
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
        
         
    end
    
    methods (Static)
       obj=map_input_cl_from_obj(ext_obj,varargin); 
    end
    
end