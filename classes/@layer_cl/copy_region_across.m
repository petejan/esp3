function copy_region_across(layer,idx_freq,active_reg,idx_freq_end)
            
            if isempty(idx_freq_end)
                idx_freq_end=1:length(layer.Transceivers);
            end
            
            Transceiver=layer.Transceivers(idx_freq);
            range_ori=Transceiver.Data.Range;
            time_ori=Transceiver.Data.Time;
            
            dr_ori=nanmean(diff(range_ori));
            dt_ori=nanmean(diff(time_ori));
            
            mask_reg_ori=active_reg.MaskReg;
            [nb_samples_ori,nb_pings_ori]=size(mask_reg_ori);
            [S_ori,P_ori]=meshgrid(1:nb_samples_ori,1:nb_pings_ori);
            
            
            for i=1:length(layer.Transceivers)
                if i==idx_freq||nansum(i==idx_freq_end)==0
                    continue;
                end
                
                Transceiver_2=layer.Transceivers(i);
                new_range=Transceiver_2.Data.Range;
                new_time=Transceiver_2.Data.Time;
                
                Sv=layer.Transceivers(i).Data.get_datamat('svdenoised');
                
                if isempty(Sv)
                    Sv=layer.Transceivers(i).Data.get_datamat('sv');
                end
                
                dr=nanmean(diff(new_range));
                dt=nanmean(diff(new_time));
                
                [~,idx_ping_start]=nanmin(abs(new_time-time_ori(active_reg.Idx_pings(1))));
                [~,sample_start]=nanmin(abs(new_range-range_ori(active_reg.Idx_r(1))));
                [~,idx_ping_end]=nanmin(abs(new_time-time_ori(active_reg.Idx_pings(end))));
                [~,sample_end]=nanmin(abs(new_range-range_ori(active_reg.Idx_r(end))));
                
                idx_pings=idx_ping_start:idx_ping_end;
                idx_r=sample_start:sample_end;
                
                switch active_reg.Cell_w_unit
                    case 'pings'
                        cell_w=nanmax(round(active_reg.Cell_w*dt_ori/dt),1);
                    case 'meters'
                        cell_w=active_reg.Cell_w;
                end
                
                switch active_reg.Cell_h_unit
                    case 'samples'
                        cell_h=nanmax(round(active_reg.Cell_h*dr_ori/dr),1);
                    case 'meters'
                        cell_h=active_reg.Cell_h;
                        
                end
                
                switch active_reg.Shape
                    case 'Polygon'
                        [nb_samples,nb_pings]=size(Sv(idx_r,idx_pings));
                        [S,P]=meshgrid(1:nb_samples,1:nb_pings);
                        F=scatteredInterpolant(S_ori(:),P_ori(:),double(mask_reg_ori(:)),'nearest','nearest');
                        MaskReg=F(S,P);   
                    otherwise
                        MaskReg=ones(length(idx_r),length(idx_pings));
                end
                
                reg_temp=region_cl(...
                    'ID',layer.Transceivers(i).new_id(),...
                    'Unique_ID',active_reg.Unique_ID,...
                    'Name',active_reg.Name,...
                    'Type',active_reg.Type,...
                    'Idx_pings',idx_pings,...
                    'Idx_r',idx_r,...
                    'Shape',active_reg.Shape,...
                    'MaskReg',MaskReg,...
                    'Reference','Surface',...
                    'Cell_w',cell_w,...
                    'Cell_w_unit',active_reg.Cell_w_unit,...
                    'Cell_h',cell_h,...
                    'Cell_h_unit',active_reg.Cell_h_unit);
                 
                layer.Transceivers(i).add_region(reg_temp);
            end
            
        end