classdef survey_options_cl
    properties
        Use_exclude_regions=1;
        Absorption=10;
        Es60_correction=0;
        Motion_correction=0;
        Shadow_zone=0;
        Shadow_zone_height=10;
        Vertical_slice_size=10;
        Vertical_slice_units='meters';
        Horizontal_slice_size=10;
        Remove_tracks=0;
        Remove_ST=0;
        Denoised=0;
        Frequency=38000;
        FrequenciesToLoad=[];
        ClassifySchool=0;
        BadTransThr=100;
        Soundspeed=1500;
        SaveBot=0;
        SaveReg=0;
        DepthMin=0;
        DepthMax=Inf;
        ExportSlicedTransects=0;
    end
    methods
        function options=survey_options_cl(varargin)
            
            default_absorption=[2.7 9.8 22.8 37.4 52.7];
            default_absorption_f=[18000 38000 70000 120000 200000];
            default_options=struct('Use_exclude_regions',1,'Absorption',nan,'Es60_correction',nan,'Motion_correction',0,...
                'Vertical_slice_size',100,...
                'Vertical_slice_units','pings',...
                'Horizontal_slice_size',10,...
                'Remove_tracks',0,'Remove_ST',0,'Denoised',0,...
                'Frequency',38000,'FrequenciesToLoad',[],...
                'ClassifySchool',0,'BadTransThr',100,...
                'Soundspeed',nan,...
                'SaveBot',0,'SaveReg',0,'Shadow_zone',0,'Shadow_zone_height',0,...
                'DepthMin',0,'DepthMax',Inf,...
                'ExportSlicedTransects',0);
            
            p = inputParser;
            
            addParameter(p,'Options',default_options);
            parse(p,varargin{:});
            
            results=p.Results;
            if isstruct(results.Options)
                props_options=fieldnames(results.Options);
            elseif isa(results.Options)
                props_options=properties(results.Options);
            end
            
            
            for i=1:length(props_options)
                if isprop(options,props_options{i})
                    options.(props_options{i})=results.Options.(props_options{i});
                end
            end
            
            options.FrequenciesToLoad=union(options.FrequenciesToLoad,results.Options.Frequency);
            
            abs_ori=options.Absorption;
            options.Absorption=nan(1,length(options.FrequenciesToLoad));
            
            if length(abs_ori)==1
                options.Absorption(options.FrequenciesToLoad==options.Frequency)=abs_ori;
            elseif length(abs_ori)==length(options.FrequenciesToLoad)
                options.Absorption=abs_ori;
            end
            
            for i=1:length(options.FrequenciesToLoad)
                idx_f=find(default_absorption_f==options.FrequenciesToLoad(i));
                if isnan(options.Absorption(i))
                    if ~isempty(idx_f)
                        options.Absorption(i)=default_absorption(idx_f);
                    end
                end
            end
            
            
        end
        
        function obj=update_options(obj,struct_opt)
            if ~isempty(struct_opt)
                f_options=fieldnames(struct_opt);
                for i=1:length(f_options)
                    if isprop(obj,f_options{i})
                        obj.(f_options{i})=struct_opt.(f_options{i});
                    end
                end
                
            end
        end
        
        function myStruct = struct(x)
            publicProperties = properties(x);
            myStruct = struct();
            for iField = 1:numel(publicProperties)
                myStruct.(publicProperties{iField}) = x.(publicProperties{iField});
            end
            
        end
    end
end