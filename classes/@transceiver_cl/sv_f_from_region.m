function [Sv_f,f_vec,ping_mat,r_mat]=sv_f_from_region(trans_obj,reg_obj,varargin)

p = inputParser;
addRequired(p,'trans_obj',@(x) isa(x,'transceiver_cl'));
addRequired(p,'reg_obj',@(x) isa(x,'region_cl'));
addParameter(p,'envdata',env_data_cl,@(x) isa(x,'env_data_cl'));
addParameter(p,'cal',[],@(x) isempty(x)|isstruct(x));
addParameter(p,'cal_eba',[],@(x) isempty(x)|isstruct(x));
addParameter(p,'load_bar_comp',[],@(x) isempty(x)|isstruct(x));
parse(p,trans_obj,reg_obj,varargin{:});

output_reg=trans_obj.integrate_region(reg_obj);
[N_y,N_x]=size(output_reg.Ping_S);


nb_samples=output_reg.Sample_E-output_reg.Sample_S;

nfft=2^nextpow2(nanmean(nb_samples(:)));

Sv_f=nan(N_y,N_x,nfft/2);
f_vec=linspace(trans_obj.Params.FrequencyStart(1),trans_obj.Params.FrequencyEnd(1),nfft/2);
ping_mat=(output_reg.Ping_S+output_reg.Ping_E)/2;
r_mat=(output_reg.Layer_depth_min+output_reg.Layer_depth_max)/2;

if ~isempty(p.Results.load_bar_comp)
  set(p.Results.load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',N_y*N_x, 'Value',0);
  p.Results.load_bar_comp.status_bar.setText('Sv Matrix Estimation');
end
for i=1:N_y
    for j=1:N_x
        if ~isempty(p.Results.load_bar_comp)
            set(p.Results.load_bar_comp.progress_bar ,'Value',j+(i-1)*N_x);
        end
        sv_f_temp=0;
        for ip=output_reg.Ping_S(i,j):output_reg.Ping_E(i,j)
            [temp,f_vec_temp]=trans_obj.processSv_f_r(p.Results.envdata,ip,output_reg.Layer_depth_min(i,j),output_reg.Layer_depth_max(i,j),p.Results.cal,p.Results.cal_eba,nfft);
            sv_f_temp=sv_f_temp+10.^(temp/10);
        end
        sv_f_temp=sv_f_temp/length(output_reg.Ping_S(i,j):output_reg.Ping_E(i,j));
        sv_f_temp=interp1(f_vec_temp,sv_f_temp,f_vec);
        Sv_f(i,j,:)=10*log10(sv_f_temp);
    end
    
end

end