function [TS_f,f_vec,pings,r_tot]=TS_f_from_region(trans_obj,reg_obj,varargin)

p = inputParser;
addRequired(p,'trans_obj',@(x) isa(x,'transceiver_cl'));
addRequired(p,'reg_obj',@(x) isa(x,'region_cl'));
addParameter(p,'envdata',env_data_cl,@(x) isa(x,'env_data_cl'));
addParameter(p,'cal',[],@(x) isempty(x)|isstruct(x));
addParameter(p,'load_bar_comp',[],@(x) isempty(x)|isstruct(x));
addParameter(p,'dp',2,@isnumeric);
parse(p,trans_obj,reg_obj,varargin{:});


range=trans_obj.get_transceiver_range(reg_obj.Idx_r);
pings=trans_obj.Data.get_numbers(reg_obj.Idx_pings);


if ~isempty(p.Results.load_bar_comp)
    set(p.Results.load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',length(pings), 'Value',0);
    p.Results.load_bar_comp.status_bar.setText('Sv Matrix Estimation');
end
[~,~,f_vec,r_tot]=trans_obj.processTS_f_v2(p.Results.envdata,1,range,p.Results.dp,p.Results.cal);

TS_f=nan(length(pings),length(r_tot),length(f_vec));


for i=1:length(pings)
    
    if ~isempty(p.Results.load_bar_comp)
        set(p.Results.load_bar_comp.progress_bar ,'Value',i);
    end
    [Sp_f,compensation_f,f_vec,r_tot]=trans_obj.processTS_f_v2(p.Results.envdata,pings(i),range,p.Results.dp,p.Results.cal);
    TS_f(i,:,:)=Sp_f+compensation_f; 
end

end