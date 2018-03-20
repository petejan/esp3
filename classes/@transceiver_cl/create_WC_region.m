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
addParameter(p,'block_len',1e7,@(x) x>0);
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
        cell_w_units='seconds'; 
        xdata=trans_obj.get_transceiver_pings();
        cell_w=p.Results.Cell_w;
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
bot_data(trans_obj.get_bottom_idx()==numel(ydata))=nan;
switch lower(p.Results.Ref)
    case 'surface'
        name='WC';
        idx_r_min=find(ydata>p.Results.y_min,1,'first');

        idxBad=trans_obj.Bottom.Tag==0;
        if all(~isnan(bot_data(~idxBad)))
        %bot_data(idxBad)=nan;
            [~,idx_r_max]=nanmin(abs(ydata-(nanmax(bot_data+p.Results.Cell_h))));
        else
            idx_r_max=length(ydata);
        end
        
        shape='Rectangular';
        if p.Results.y_max~=Inf
            idx_r_y_max=find(ydata<=p.Results.y_max,1,'last');
            idx_r_max=nanmin(idx_r_max,idx_r_y_max);
        end
        mask=[]; idx_r=idx_r_min:idx_r_max;
    case 'bottom'
        name='WC';
        %idxBad=trans_obj.Bottom.Tag==0;
        
        %bot_data(idxBad)=nan;
        shape='Polygon';
        
        mask=false(numel(ydata),nb_pings);
        block_size=ceil(p.Results.block_len/numel(ydata));
        num_ite=ceil(nb_pings/block_size);
        
        idx_pings_tot=1:nb_pings;
        for ui=1:num_ite
            idx_pings=idx_pings_tot((ui-1)*block_size+1:nanmin(ui*block_size,numel(idx_pings_tot)));
            mask(:,idx_pings)=bsxfun(@ge,ydata,bot_data(idx_pings)-p.Results.y_max)&...
                bsxfun(@le,ydata,bot_data(idx_pings)-p.Results.y_min);
        end
        
        idx_r=find(nansum(mask,2)>0,1,'first'):find(nansum(mask,2)>0,1,'last');
        mask=mask(idx_r,:);
                
end

if isempty(idx_r)||isempty(idx_pings)
    reg_wc=[];
else
    reg_wc=region_cl(...
        'ID',trans_obj.new_id(),...
        'Shape',shape,...
        'MaskReg',mask,...
        'Name',name,...
        'Type',p.Results.Type,...
        'Idx_pings',idx_pings_tot,...
        'Idx_r',idx_r,...
        'Reference',p.Results.Ref,...
        'Cell_w',cell_w,...
        'Cell_w_unit',cell_w_units,...
        'Cell_h',p.Results.Cell_h,...
        'Cell_h_unit',p.Results.Cell_h_unit,...
        'Remove_ST',p.Results.Remove_ST);
end

end
