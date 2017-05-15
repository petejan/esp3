classdef mbs_header_cl
    properties
        Script='';
        MbsId='';
        title='';
        main_species='';
        voyage='';
        areas='';
        author='';
        created='';
        vertical_slice_size=10;
        comments='';
        use_exclude_regions='yes';
        default_absorption=8;
        es60_correction='no';
        motion_correction='no';
        shadow_zone_correction='no';
        shadow_zone_extrapolate_height=10;
        shadow_zone_extrapolate_type='';
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