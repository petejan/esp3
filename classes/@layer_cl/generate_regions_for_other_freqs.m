function [regs,idx_freq_end,r_factor,t_factor]=generate_regions_for_other_freqs(layer,idx_freq,active_reg,idx_freq_end)

if isempty(idx_freq_end)
    idx_freq_end=1:length(layer.Transceivers);
end

idx_freq_end=setdiff(idx_freq_end,idx_freq);
r_factor=ones(1,numel(idx_freq_end));
t_factor=ones(1,numel(idx_freq_end));
trans_obj=layer.Transceivers(idx_freq);

range_ori=trans_obj.get_transceiver_range();
time_ori=trans_obj.Time;

dr_ori=nanmean(diff(range_ori));
dt_ori=nanmean(diff(time_ori));

mask_reg_ori=active_reg.get_mask();

[nb_samples_ori,nb_pings_ori]=size(mask_reg_ori);
regs=[];
u=0;
for i=1:length(layer.Transceivers)
    
    if i==idx_freq||~any(i==idx_freq_end)
        continue;
    end
    u=u+1;
    trans_obj_sec=layer.Transceivers(i);
    new_range=trans_obj_sec.get_transceiver_range();
    new_time=trans_obj_sec.Time;
    
    r_factor(u)=dr_ori/nanmean(diff(new_range));
    t_factor(u)=dt_ori/nanmean(diff(new_time));
    
    [~,idx_ping_start]=nanmin(abs(new_time-time_ori(active_reg.Idx_pings(1))));
    [~,sample_start]=nanmin(abs(new_range-range_ori(active_reg.Idx_r(1))));
    [~,idx_ping_end]=nanmin(abs(new_time-time_ori(active_reg.Idx_pings(end))));
    [~,sample_end]=nanmin(abs(new_range-range_ori(active_reg.Idx_r(end))));
    
    idx_pings=idx_ping_start:idx_ping_end;
    idx_r=(sample_start:sample_end)';
    
    switch active_reg.Cell_w_unit
        case 'pings'
            cell_w=nanmax(ceil(active_reg.Cell_w*t_factor(u)),1);
        case 'meters'
            cell_w=active_reg.Cell_w;
    end
    
    switch active_reg.Cell_h_unit
        case 'samples'
            cell_h=nanmax(ceil(active_reg.Cell_h*r_factor(u)),1);
        case 'meters'
            cell_h=active_reg.Cell_h;            
    end
    
    switch active_reg.Shape
        case 'Polygon'
            nb_samples=length(idx_r);
            nb_pings=length(idx_pings);
            if nb_samples~=nb_samples_ori||nb_pings~=nb_pings_ori
                MaskReg=imresize(mask_reg_ori,[nb_samples nb_pings],'nearest');
            else
                MaskReg=mask_reg_ori;
            end
        otherwise
            MaskReg=ones(length(idx_r),length(idx_pings));
    end

    
%     poly=active_reg.Poly;
%     poly.Vertices(:,1)=floor(poly.Vertices(:,1)*t_factor);
%     poly.Vertices(:,2)=floor(poly.Vertices(:,2)*r_factor);
try
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
        'Reference',active_reg.Reference,...
        'Cell_w',cell_w,...
        'Cell_w_unit',active_reg.Cell_w_unit,...
        'Cell_h',cell_h,...
        'Cell_h_unit',active_reg.Cell_h_unit)];
catch
    warning('Could not copy region %d to channel %s',active_reg.ID,layer.Transceivers(i).Config.ChannelID);
    idx_freq_end(idx_freq_end==i)=[];
end
    
end

end