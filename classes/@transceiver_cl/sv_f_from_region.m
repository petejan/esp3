function [Sv_f,f_vec,pings,r_tot]=sv_f_from_region(trans_obj,reg_obj,varargin)

p = inputParser;
addRequired(p,'trans_obj',@(x) isa(x,'transceiver_cl'));
addRequired(p,'reg_obj',@(x) isa(x,'region_cl'));
addParameter(p,'envdata',env_data_cl,@(x) isa(x,'env_data_cl'));
addParameter(p,'cal',[],@(x) isempty(x)|isstruct(x));
addParameter(p,'cal_eba',[],@(x) isempty(x)|isstruct(x));
addParameter(p,'load_bar_comp',[],@(x) isempty(x)|isstruct(x));
parse(p,trans_obj,reg_obj,varargin{:});

output_reg=trans_obj.integrate_region(reg_obj);
if isempty(output_reg)
    Sv_f=[];
    f_vec=[];
    pings=[];
    r_tot=[];
    return;
end

[N_y,N_x]=size(output_reg.Ping_S);


range=trans_obj.get_transceiver_range(reg_obj.Idx_r);
pings=trans_obj.get_transceiver_pings(reg_obj.Idx_pings);

[~,Np]=trans_obj.get_pulse_length();

if ~isempty(p.Results.load_bar_comp)
  set(p.Results.load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',N_y*N_x, 'Value',0);
  p.Results.load_bar_comp.status_bar.setText('Sv Matrix Estimation');
end

[~,f_vec,r_tot]=trans_obj.processSv_f_r_2(p.Results.envdata,1,range,Np,p.Results.cal,p.Results.cal_eba);
Sv_f=nan(length(pings),length(r_tot),length(f_vec));


for i=1:length(pings)
    
    if ~isempty(p.Results.load_bar_comp)
        set(p.Results.load_bar_comp.progress_bar ,'Value',i);
    end
     [Sv_f(i,:,:),~,~]=trans_obj.processSv_f_r_2(p.Results.envdata,pings(i),range,Np,p.Results.cal,p.Results.cal_eba);

end

    
end
