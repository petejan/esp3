function create_track_regs(trans_obj,varargin)

p = inputParser;

check_type=@(type) ~isempty(strcmp(type,{'Data','Bad Data'}));

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addParameter(p,'Type','Data',check_type);
parse(p,trans_obj,varargin{:});

[~,Np]=trans_obj.get_pulse_length();
nb_samples=length(trans_obj.Data.Range);
nb_pings=length(trans_obj.Data.Time);
ST=trans_obj.ST;
tracks=trans_obj.Tracks;
idx_pings_st=ST.Ping_number;
idx_r_st=ST.idx_r;
trans_obj.rm_region_name('Track');

if ~isempty(tracks)
    for k=1:length(tracks.target_id)
        
        
        idx_targets=tracks.target_id{k};
        
        %idx_r=max(1,min(idx_r_st(idx_targets)-Np)):min(max(idx_r_st(idx_targets))+Np,nb_samples);
        idx_pings=max(1,min(idx_pings_st(idx_targets)-2)):min(max(idx_pings_st(idx_targets))+2,nb_pings);
        idx_r_tracks=round(interp1(idx_pings_st(idx_targets),idx_r_st(idx_targets),idx_pings,'spline'));
        
        idx_r=max(1,min(idx_r_tracks-ceil(3/2*Np))):min(max(idx_r_tracks)+ceil(5/2*Np),nb_samples);

        Sv_reg=nan(length(idx_r),length(idx_pings));
        Sv_reg((idx_r_tracks-min(idx_r)+1)+(idx_pings-min(idx_pings))*(length(idx_r)))=1;
        Sv_reg=ceil(filter2_perso(ones(3*Np,1),Sv_reg));

        
        reg_temp=region_cl(...
            'ID',trans_obj.new_id(),...
            'Name','Track',...
            'Type',p.Results.Type,...
            'Idx_pings',idx_pings,...
            'Idx_r',idx_r,...
            'Shape','Polygon',...
            'Reference','Surface',...
            'Sv_reg',Sv_reg,...
            'Cell_w',1,...
            'Cell_w_unit','pings',...
            'Cell_h',1,...
            'Cell_h_unit','samples');
      
        trans_obj.add_region(reg_temp);
    end
    
end

end



