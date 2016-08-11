function [regs,idx_freq_end]=generate_regions_for_other_freqs(layer,idx_freq,active_reg,idx_freq_end)

if isempty(idx_freq_end)
    idx_freq_end=1:length(layer.Transceivers);
end

idx_freq_end=setdiff(idx_freq_end,idx_freq);

Transceiver=layer.Transceivers(idx_freq);
range_ori=Transceiver.Data.get_range();
time_ori=Transceiver.Data.Time;

dr_ori=nanmean(diff(range_ori));
dt_ori=nanmean(diff(time_ori));

mask_reg_ori=active_reg.get_mask();

[nb_samples_ori,nb_pings_ori]=size(mask_reg_ori);
[P_ori,S_ori]=meshgrid(1:nb_pings_ori,1:nb_samples_ori);
regs=[];

for i=1:length(layer.Transceivers)
    if i==idx_freq||nansum(i==idx_freq_end)==0
        continue;
    end
    
    layer.Transceivers(i)=layer.Transceivers(i);
    new_range=layer.Transceivers(i).Data.get_range();
    new_time=layer.Transceivers(i).Data.Time;
    

    
    r_factor=dr_ori/nanmean(diff(new_range));
    t_factor=dt_ori/nanmean(diff(new_time));
    
    [~,idx_ping_start]=nanmin(abs(new_time-time_ori(active_reg.Idx_pings(1))));
    [~,sample_start]=nanmin(abs(new_range-range_ori(active_reg.Idx_r(1))));
    [~,idx_ping_end]=nanmin(abs(new_time-time_ori(active_reg.Idx_pings(end))));
    [~,sample_end]=nanmin(abs(new_range-range_ori(active_reg.Idx_r(end))));
    
    idx_pings=idx_ping_start:idx_ping_end;
    idx_r=sample_start:sample_end;
    
    switch active_reg.Cell_w_unit
        case 'pings'
            cell_w=nanmax(round(active_reg.Cell_w*t_factor),1);
        case 'meters'
            cell_w=active_reg.Cell_w;
    end
    
    switch active_reg.Cell_h_unit
        case 'samples'
            cell_h=nanmax(round(active_reg.Cell_h*r_factor),1);
        case 'meters'
            cell_h=active_reg.Cell_h;
            
    end
    
    switch active_reg.Shape
        case 'Polygon'
                nb_samples=length(idx_r);
                nb_pings=length(idx_pings);
            if nb_samples~=nb_samples_ori||nb_pings~=nb_pings_ori
                [P,S]=meshgrid((1:nb_pings),(1:nb_samples));
                F=scatteredInterpolant(S_ori(:),P_ori(:),double(mask_reg_ori(:)),'nearest','nearest');
                MaskReg=F(S,P);
            else
                MaskReg=mask_reg_ori;
            end
        otherwise
            MaskReg=ones(length(idx_r),length(idx_pings));
    end
    
    regs=[regs region_cl(...
        'ID',active_reg.ID,...
        'Unique_ID',active_reg.Unique_ID,...
        'Name',active_reg.Name,...
        'Type',active_reg.Type,...
        'Tag',active_reg.Tag,...
        'Idx_pings',idx_pings,...
        'Idx_r',idx_r,...
        'Shape',active_reg.Shape,...
        'MaskReg',MaskReg,...
        'Reference','Surface',...
        'Cell_w',cell_w,...
        'Cell_w_unit',active_reg.Cell_w_unit,...
        'Cell_h',cell_h,...
        'Cell_h_unit',active_reg.Cell_h_unit)];
    
end

end