classdef survey_input_cl < handle
    properties
        
        Infos
        Options
        Cal
        Algos
        Regions_WC
        Snapshots
        
    end
    
    
    methods
        function surv_input_obj=survey_input_cl(varargin)
            
            p = inputParser;
            
            
            default_info=struct('Script','','XmlId','','Title','','Main_species','','Areas','','Voyage','','Author','','Created','','Comments','');
            default_cal=struct('G0',25.10,'SACORRECT',0.0);
            default_options=struct('Use_exclude_regions',1,'Absorption',nan,'Es60_correction',0,'Motion_correction',0,...
                'Vertical_slice_size',100,'Vertical_slice_units','pings','Horizontal_slice_size',10,'Remove_tracks',0,'Remove_ST',0,'Frequency',38000,'FrequenciesToLoad',[],'FileType','Raw');
            default_absorption=[2.7 9.8 22.8 37.4 52.7];
            default_absorption_f=[18000 38000 70000 120000 200000];
            
            
            addParameter(p,'Infos',default_info);
            addParameter(p,'Cal',default_cal);
            addParameter(p,'Options',default_options);
            addParameter(p,'Algos',{});
            addParameter(p,'Regions_WC',{});
            addParameter(p,'Snapshots',struct('number',0,'folder','','stratum',{}));
            parse(p,varargin{:});
            
            
            results=p.Results;
            props_infos=fieldnames(results.Infos);
            props_options=fieldnames(results.Options);
            
            surv_input_obj.Options=default_options;
            for i=1:length(props_options)
                surv_input_obj.Options.(props_options{i})=results.Options.(props_options{i});
            end
            
            surv_input_obj.Infos=default_info;
            for i=1:length(props_infos)
                surv_input_obj.Infos.(props_infos{i})=results.Infos.(props_infos{i});
            end
            
            if isnan(surv_input_obj.Options.Absorption)
                idx_f=find(default_absorption_f==surv_input_obj.Options.Frequency);
                if ~isempty(idx_f)
                    surv_input_obj.Options.Absorption=default_absorption(idx_f);
                end
            end
            
            surv_input_obj.Algos=results.Algos;
            surv_input_obj.Cal=results.Cal;
            surv_input_obj.Regions_WC=results.Regions_WC;
            surv_input_obj.Snapshots=results.Snapshots;
            
        end
        
        function [snapshot_vec,stratum_vec,transect_vec,reg_num_vec]=list_transects(surv_in_obj)
            snapshots=surv_in_obj.Snapshots;
            nb_trans=0;
            snapshot_vec=[];
            stratum_vec={};
            transect_vec=[];
            reg_num_vec=[];
            
            for isn=1:length(snapshots)
                snap_num=snapshots{isn}.Number;
                stratum=snapshots{isn}.Stratum;
                for ist=1:length(stratum)
                    strat_name=stratum{ist}.Name;
                    transects=stratum{ist}.Transects;
                    for itr=1:length(transects)
                        nb_trans=nb_trans+1;
                        trans_num=transects{itr}.number;
                        snapshot_vec(nb_trans)=snap_num;
                        stratum_vec{nb_trans}=strat_name;
                        transect_vec(nb_trans)=trans_num;
                    end
                end
                
            end
        end
        
    end
end