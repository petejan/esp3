function reg_wc=create_WC_region(trans_obj,varargin)

p = inputParser;

check_w_unit=@(unit) ~isempty(strcmp(unit,{'pings','meters'}));
check_h_unit=@(unit) ~isempty(strcmp(unit,{'samples','meters'}));
check_ref=@(ref) ~isempty(strcmp(ref,{'Surface','Bottom'}));
check_dataType=@(data) ~isempty(strcmp(data,{'Data','Bad Data'}));

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addParameter(p,'y_min',10,@isnumeric)
addParameter(p,'y_max',inf,@isnumeric)
addParameter(p,'t_min',0,@isnumeric)
addParameter(p,'t_max',inf,@isnumeric)
addParameter(p,'Type','Data',check_dataType);
addParameter(p,'Ref','Surface',check_ref);
addParameter(p,'Cell_w',10,@isnumeric);
addParameter(p,'Cell_h',10,@isnumeric);
addParameter(p,'Cell_w_unit','pings',check_w_unit);
addParameter(p,'Cell_h_unit','meters',check_h_unit);
addParameter(p,'Remove_ST',0,@isnumeric);
parse(p,trans_obj,varargin{:});

switch p.Results.Cell_w_unit
    case 'pings'
        xdata=trans_obj.get_transceiver_pings();
        cell_w=p.Results.Cell_w;
        cell_w_units='pings';
    case 'meters'
        if ~isempty(trans_obj.GPSDataPing.Dist)
            xdata=trans_obj.GPSDataPing.Dist;
            cell_w=p.Results.Cell_w;
            cell_w_units='meters';
        else
            cell_w_units='pings';
            cell_w=p.Results.Cell_w;
            xdata=trans_obj.get_transceiver_pings();
        end
    case 'seconds'
        xdata=trans_obj.get_transceiver_pings();
        cell_w_units='pings';
        cell_w=ceil(p.Results.Cell_w/nanmean(diff(trans_obj.get_transceiver_time()*24*60*60)));
end

switch p.Results.Cell_h_unit
    case 'samples'
        ydata=trans_obj.get_transceiver_samples();
        bot_data=trans_obj.get_bottom_idx();
    case 'meters'
        ydata=trans_obj.get_transceiver_range();
        bot_data=trans_obj.get_bottom_range();
end
nb_pings=length(xdata);

time_t=trans_obj.Params.Time();

idx_pings=find(time_t>=p.Results.t_min&time_t<=p.Results.t_max);

switch lower(p.Results.Ref)
    case 'surface'
        name='WC';
        [~,idx_r_min]=nanmin(abs(ydata-p.Results.y_min));
        idxBad=trans_obj.Bottom.Tag==0;
        bot_data(idxBad)=nan;
        
        if nansum(isnan(bot_data))<nb_pings
            [~,idx_r_max]=nanmin(abs(ydata-(nanmax(bot_data+p.Results.Cell_h))));
        else
            idx_r_max=length(ydata);
        end
   
        shape='Rectangular';
        if p.Results.y_max~=Inf
            [~,idx_r_y_max]=nanmin(abs(ydata-p.Results.y_max));
            idx_r_max=nanmin(idx_r_max,idx_r_y_max);
        end
        mask=[]; idx_r=idx_r_min:idx_r_max;
    case 'bottom' 
        name='WC';
        idxBad=trans_obj.Bottom.Tag==0;
        bot_data(idxBad)=nan;
        shape='Polygon';
        
        mask=bsxfun(@ge,ydata,bot_data-p.Results.y_max)&...
        bsxfun(@le,ydata,bot_data+p.Results.Cell_h)&...
        bsxfun(@ge,ydata,repmat(p.Results.y_min,size(bot_data)));
    
        idx_r=find(nansum(mask,2)>0,1,'first'):find(nansum(mask,2)>0,1,'last');
        mask=mask(idx_r,:);
end


 
reg_wc=region_cl(...
    'ID',trans_obj.new_id(),...
    'Shape',shape,...
    'MaskReg',mask,...
    'Name',name,...
    'Type',p.Results.Type,...
    'Idx_pings',idx_pings,...
    'Idx_r',idx_r,...
    'Reference',p.Results.Ref,...
    'Cell_w',cell_w,...
    'Cell_w_unit',cell_w_units,...
    'Cell_h',p.Results.Cell_h,...
    'Cell_h_unit',p.Results.Cell_h_unit,...
    'Remove_ST',p.Results.Remove_ST);

end
