classdef survey_output_cl < handle
    properties 
        stratumSum
        transectSum
        transectSumTracks
        slicedTransectSum
        regionSum
        regionSumAbscf
        regionSumVbscf
        regionsIntegrated
    end
    
    
    methods
        function obj=survey_output_cl(nb_strat,nb_trans,nb_reg)
            

            p = inputParser;
            addRequired(p,'nb_strat',@(x) x>0);
            addRequired(p,'nb_trans',@(x) x>0);
            addRequired(p,'nb_reg',@(x) x>=0);
            parse(p,nb_strat,nb_trans,nb_reg);
            
   
            mat_de=nan(1,nb_strat);
            cell_de={cell(1,nb_strat)};
            obj.stratumSum =struct('snapshot',mat_de,'stratum',cell_de,'no_transects',mat_de,'abscf_mean',mat_de,'abscf_sd',mat_de,'abscf_wmean',mat_de,'abscf_var',mat_de,'time_start',mat_de,'time_end',mat_de);
            
            mat_de=nan(1,nb_trans);
            cell_de={cell(1,nb_trans)};
            obj.transectSum = struct('snapshot',mat_de,'stratum',cell_de,'transect',mat_de,'dist',mat_de,'vbscf',mat_de,'abscf',mat_de,'mean_d',mat_de,'pings',mat_de,'av_speed',mat_de,'start_lat',mat_de,'start_lon',mat_de,'finish_lat',mat_de,'finish_lon',mat_de,'time_start',mat_de,'time_end',mat_de);
            obj.transectSumTracks= struct('snapshot',mat_de,'stratum',cell_de,'transect',mat_de,'nb_st',mat_de,'nb_tracks',mat_de,'lat_track',cell_de,'lon_track',cell_de,'depth_track',cell_de,'time_track',cell_de,'TS_mean_track',cell_de,'ping_num_track',cell_de);
            obj.slicedTransectSum = struct('snapshot',mat_de,'stratum',cell_de,'transect',mat_de,'slice_size',mat_de,'num_slices',mat_de,'latitude',cell_de,'longitude',cell_de,'slice_abscf',cell_de,'time_start',cell_de,'time_end',cell_de,'slice_nb_tracks',cell_de,'slice_nb_st',cell_de);
            
            mat_de=nan(1,nb_reg);
            cell_de={cell(1,nb_reg)};
            obj.regionSum = struct('snapshot',mat_de,'stratum',cell_de,'transect',mat_de,'file',cell_de,'region_id',mat_de,'ref',cell_de,'slice_size',mat_de,'good_pings',mat_de,'start_d',mat_de,'mean_d',mat_de,'finish_d',mat_de,'av_speed',mat_de,'vbscf',mat_de,'abscf',mat_de,'time_start',mat_de,'time_end',mat_de);
            obj.regionSumAbscf = struct('snapshot',mat_de,'stratum',cell_de,'transect',mat_de,'file',cell_de,'region_id',mat_de,'num_v_slices',mat_de,'transmit_start',cell_de,'latitude',cell_de,'longitude',cell_de,'column_abscf',cell_de,'time_start',cell_de,'time_end',cell_de);
            obj.regionSumVbscf = struct('snapshot',mat_de,'stratum',cell_de,'transect',mat_de,'file',cell_de,'region_id',mat_de,'num_h_slices',mat_de,'num_v_slices',mat_de,'region_vbscf',mat_de,'vbscf_values',cell_de,'time_start',cell_de,'time_end',cell_de);
            
            obj.regionsIntegrated= struct('snapshot',mat_de,'stratum',cell_de,'transect',mat_de,'file',cell_de,'Region',cell_de,'RegOutput',cell_de);
                end
        
    end
    
end