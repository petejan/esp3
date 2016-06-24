function single_targets=single_targets_detection(Transceiver,varargin)
%SINGLE_TARGET_DETECTION
tic;
%Parse Arguments
p = inputParser;

check_trans_cl=@(obj)isa(obj,'transceiver_cl');
defaultTsThr=-50;
checkTsThr=@(thr)(thr>=-120&&thr<=-20);
defaultPLDL=6;
checkPLDL=@(PLDL)(PLDL>=1&&PLDL<=30);
defaultMinNormPL=0.7;
defaultMaxNormPL=1.5;
checkNormPL=@(NormPL)(NormPL>=0.0&&NormPL<=10);
defaultMaxBeamComp=4;
checkBeamComp=@(BeamComp)(BeamComp>=0&&BeamComp<=18);
defaultMaxStdMinAxisAngle=0.6;
checkMaxStdMinAxisAngle=@(MaxStdMinAxisAngle)(MaxStdMinAxisAngle>=0&&MaxStdMinAxisAngle<=45);
defaultMaxStdMajAxisAngle=0.6;
checkMaxStdMajAxisAngle=@(MaxStdMajAxisAngle)(MaxStdMajAxisAngle>=0&&MaxStdMajAxisAngle<=45);

check_data_type=@(datatype) ischar(datatype)&&(nansum(strcmp(datatype,{'CW','FM'}))==1);


addRequired(p,'Transceiver',check_trans_cl);
addParameter(p,'SoundSpeed',1500,@isnumeric);
addParameter(p,'Type','sp',@ischar);
addParameter(p,'TS_threshold',defaultTsThr,checkTsThr);
addParameter(p,'PLDL',defaultPLDL,checkPLDL);
addParameter(p,'MinNormPL',defaultMinNormPL,checkNormPL);
addParameter(p,'MaxNormPL',defaultMaxNormPL,checkNormPL);
addParameter(p,'MaxBeamComp',defaultMaxBeamComp,checkBeamComp);
addParameter(p,'MaxStdMinAxisAngle',defaultMaxStdMinAxisAngle,checkMaxStdMinAxisAngle);
addParameter(p,'MaxStdMajAxisAngle',defaultMaxStdMajAxisAngle,checkMaxStdMajAxisAngle);
addParameter(p,'DataType','CW',check_data_type);


parse(p,Transceiver,varargin{:});
max_TS=-10;

%Initialize usefule variables

switch p.Results.DataType
    case 'CW'
        TS=Transceiver.Data.get_datamat(p.Results.Type);
        if isempty(TS)
             TS=Transceiver.Data.get_datamat('sp');
        end
        if isempty(TS)
            disp('Can''t find single targets with no Sp datagram...');
            single_targets=[];
            return;
        end
    case 'FM'
        TSun=Transceiver.Data.get_datamat('spunmatched');
        TS=Transceiver.Data.get_datamat('sp');
end
    

mask=zeros(size(TS));

idx_bad_data=Transceiver.list_regions_type('Bad Data');

for jj=1:length(idx_bad_data)
   curr_reg=Transceiver.Regions(idx_bad_data(jj));
   mask(curr_reg.Idx_r,curr_reg.Idx_pings)=mask(curr_reg.Idx_r,curr_reg.Idx_pings)+curr_reg.create_mask();
end

TS(mask>=1)=-999;


[nb_samples,nb_pings]=size(TS);

Idx_samples_lin=reshape(1:nb_samples*nb_pings,nb_samples,nb_pings);

Bottom=Transceiver.Bottom.Range;
if isempty(Bottom)
    Bottom=ones(1,nb_pings)*Range(end);
end

Range=repmat(Transceiver.Data.get_range(1:nb_samples),1,nb_pings);


under_bottom=Range>repmat(Bottom,nb_samples,1);
TS(under_bottom)=-999;

idx_r_max=find(Transceiver.Data.get_range()==nanmax(Range(TS>-999)));%%TODO but

%%%%%%%Remove all unnecessary data%%%%%%%%

TS(idx_r_max:end,:)=[];
Idx_samples_lin(idx_r_max:end,:)=[];
[nb_samples,nb_pings]=size(TS);
along=Transceiver.Data.get_subdatamat(1:nb_samples,1:nb_pings,'field','AlongAngle');
athwart=Transceiver.Data.get_subdatamat(1:nb_samples,1:nb_pings,'field','AcrossAngle');
if isempty(along)||isempty(along)
   disp('Cannot compute single targets.... No angles');
   single_targets=[];
   return;
end

Range=repmat(Transceiver.Data.get_range(1:nb_samples),1,nb_pings);
Samples=repmat((1:nb_samples)',1,nb_pings);
Ping=repmat(Transceiver.Data.get_numbers(),nb_samples,1);


[T,Np]=Transceiver.get_pulse_length();
%[T,Np]=Transceiver.get_pulse_Comp_length();

switch p.Results.DataType
    case 'CW'
        simu_pulse=ones(1,Np);
    case 'FM'
       TSun(idx_r_max:end,:)=[];
        [simu_pulse,~]=generate_sim_pulse(Transceiver.Params,Transceiver.Filters(1),Transceiver.Filters(2));   
        Np=4;
end

Pulse_length_sample=Np*ones(size(TS));

BW_athwart=Transceiver.Config.BeamWidthAthwartship;
BW_along=Transceiver.Config.BeamWidthAlongship;

Pulse_length_max_sample=ceil(Pulse_length_sample.*p.Results.MaxNormPL);
Pulse_length_min_sample=floor(Pulse_length_sample.*p.Results.MinNormPL);

c=p.Results.SoundSpeed;
alpha=Transceiver.Params.Absorption;

%Calculate simradBeamCompensation
simradBeamCompensation = 6.0206 * ((2*along/BW_along).^2 + (2*athwart/BW_athwart).^2 - 0.18*(2*along/BW_along).^2.*(2*athwart/BW_athwart).^2);


idx_comp=simradBeamCompensation<=p.Results.MaxBeamComp;
TVG_mat=double(real(40*log10(Range-c*T/4))+2*alpha*(Range-c*T/4));
TVG_mat(TVG_mat<=0)=nan;
Power=TS-TVG_mat;


%Find local Maxima excluding samples where the Beam compensation is over
%the threshold asked (p.Results.MaxBeamComp).
%peak_calc='power';
peak_calc='TS';

switch peak_calc
    case'power'
        peak_mat=Power;
    case'TS'
        peak_mat=TS;
end

idx_peaks=zeros(nb_samples,nb_pings);

switch p.Results.DataType
    case 'CW'
        peak_mat=10*log10(filter2(ones(floor(Np/2),1),10.^(peak_mat/10))./filter2(ones(floor(Np/2),1),ones(size(peak_mat))));
        idx_peaks=idx_comp;
        
        for i=1:floor(Np/4)+2
            idx_peaks=idx_peaks&(peak_mat>=[nan(i,nb_pings);peak_mat(1:nb_samples-i,:)])&(peak_mat>=[peak_mat(i+1:nb_samples,:);nan(i,nb_pings)]);
        end
        
        diff_idx_peaks=[zeros(1,nb_pings);diff(idx_peaks)];
        idx_peaks=(diff_idx_peaks==1);
        
    case 'FM'        
        corr=correlogramm_v2(10.^(TSun/10),abs(simu_pulse));
        idx_peaks=corr>0.6;
end


% idx_peaks=idx_peaks&(peak_mat>=[nan(1,nb_pings);peak_mat(1:nb_samples-1,:)]&peak_mat>=[peak_mat(2:nb_samples,:);nan(1,nb_pings)])...
%      &idx_comp;

%Level of the local maxima (power dB)...
idx_peaks_lin = find(idx_peaks);
[i_peaks_lin,j_peaks_lin] = find(idx_peaks);
nb_peaks=length(idx_peaks_lin);
pulse_level=peak_mat(idx_peaks_lin)-p.Results.PLDL;
idx_samples_lin=Idx_samples_lin(idx_peaks);
pulse_env_after_lin=zeros(nb_peaks,1);
pulse_env_before_lin=zeros(nb_peaks,1);
idx_sup_after=ones(nb_peaks,1);
idx_sup_before=ones(nb_peaks,1);
max_pulse_length=nanmax(Pulse_length_max_sample(:));


for j=1:max_pulse_length
    idx_sup_before=idx_sup_before.*(pulse_level<=peak_mat(nanmax(i_peaks_lin-j,1)+(j_peaks_lin-1)*nb_samples));

    idx_sup_after=idx_sup_after.*(pulse_level<=peak_mat(nanmin(i_peaks_lin+j,nb_samples)+(j_peaks_lin-1)*nb_samples));
    pulse_env_before_lin=pulse_env_before_lin+idx_sup_before;
    pulse_env_after_lin=pulse_env_after_lin+idx_sup_after;
end

temp_pulse_length_sample=Pulse_length_sample(idx_peaks);
pulse_length_lin=pulse_env_before_lin+pulse_env_after_lin+1;
idx_good_pulses=(pulse_length_lin<=Pulse_length_max_sample(idx_peaks))&(pulse_length_lin>=Pulse_length_min_sample(idx_peaks));

idx_target_lin=idx_peaks_lin(idx_good_pulses);
idx_samples_lin=idx_samples_lin(idx_good_pulses);
pulse_length_lin=pulse_length_lin(idx_good_pulses);
pulse_length_trans_lin=temp_pulse_length_sample;
pulse_env_before_lin=pulse_env_before_lin(idx_good_pulses);
pulse_env_after_lin=pulse_env_after_lin(idx_good_pulses);

nb_targets=length(idx_target_lin);


samples_targets_power=nan(max_pulse_length,nb_targets);
samples_targets_comp=nan(max_pulse_length,nb_targets);
samples_targets_range=nan(max_pulse_length,nb_targets);
samples_targets_sample=nan(max_pulse_length,nb_targets);
samples_targets_along=nan(max_pulse_length,nb_targets);
samples_targets_athwart=nan(max_pulse_length,nb_targets);
target_ping_number=nan(1,nb_targets);
target_time=nan(1,nb_targets);


h = waitbar(0,sprintf('Target %i/%i',2,nb_targets),'Name','Single Targets detection : step 1');

for i=1:nb_targets
    if mod(i,floor(nb_targets/10))==0
        waitbar(i/nb_targets,h,sprintf('Target %i/%i',i,nb_targets));
    end
    idx_pulse=idx_target_lin(i)-pulse_env_before_lin(i):idx_target_lin(i)+pulse_env_after_lin(i);
    samples_targets_power(1:pulse_length_lin(i),i)=Power(idx_pulse);
    samples_targets_comp(1:pulse_length_lin(i),i)=simradBeamCompensation(idx_pulse);
    samples_targets_range(1:pulse_length_lin(i),i)=Range(idx_pulse);
    samples_targets_sample(1:pulse_length_lin(i),i)=Samples(idx_pulse);
    samples_targets_along(1:pulse_length_lin(i),i)=along(idx_pulse);
    samples_targets_athwart(1:pulse_length_lin(i),i)=athwart(idx_pulse);
    target_ping_number(i)=Ping(idx_target_lin(i));
    target_time(i)=Ping(idx_target_lin(i));
end
close(h);
[target_peak_power,idx_peak_power]=nanmax(samples_targets_power);
target_comp=samples_targets_comp(idx_peak_power+(0:nb_targets-1)*max_pulse_length);
samples_targets_idx_r=nanmin(samples_targets_sample)+idx_peak_power-1;

std_along=nanstd(samples_targets_along);
std_athwart=nanstd(samples_targets_athwart);
phi_along=nanmean(samples_targets_along);
phi_athwart=nanmean(samples_targets_athwart);

samples_targets_power(:,std_along>p.Results.MaxStdMinAxisAngle|std_athwart>p.Results.MaxStdMajAxisAngle)=nan;
samples_targets_range(:,std_along>p.Results.MaxStdMinAxisAngle|std_athwart>p.Results.MaxStdMajAxisAngle)=nan;


switch Transceiver.Mode
    case 'CW'
        dr=double(c*T/4);
        target_range=nansum(samples_targets_power.*samples_targets_range)./nansum(samples_targets_power)-dr;
    otherwise
        [~,target_range_idx]=nanmin(samples_targets_power);
        target_range=samples_targets_range(target_range_idx+size(samples_targets_range,1)*(0:size(samples_targets_range,2)-1));
        dr=0;
end
target_range(target_range<0)=0;

target_range_min=nanmin(samples_targets_range);
target_range_max=nanmax(samples_targets_range);


TVG=real(40*log10(target_range))+double(2*alpha*target_range);

target_TS_uncomp=target_peak_power+TVG;
target_TS_comp=target_TS_uncomp+target_comp;
target_TS_comp(target_TS_comp<=p.Results.TS_threshold|target_comp>p.Results.MaxBeamComp|target_TS_comp>max_TS)=nan;
target_TS_uncomp(target_TS_comp<=p.Results.TS_threshold|target_comp>p.Results.MaxBeamComp|target_TS_comp>max_TS)=nan;

%removing all non-valid_targets again...
idx_keep= ~isnan(target_TS_comp);
pulse_length_lin=pulse_length_lin(idx_keep);
pulse_length_trans_lin=pulse_length_trans_lin(idx_keep);
target_TS_comp=target_TS_comp(idx_keep);
target_TS_uncomp=target_TS_uncomp(idx_keep);
target_range=target_range(idx_keep);
target_range_min=target_range_min(idx_keep);
target_range_max=target_range_max(idx_keep);
target_idx_r=samples_targets_idx_r(idx_keep);
std_along=std_along(idx_keep);
std_athwart=std_athwart(idx_keep);
phi_along=phi_along(idx_keep);
phi_athwart=phi_athwart(idx_keep);
target_ping_number=target_ping_number(idx_keep);
target_time=target_time(idx_keep);
nb_valid_targets=nansum(idx_keep);
idx_target_lin=idx_target_lin(idx_keep);
idx_samples_lin=idx_samples_lin(idx_keep);
pulse_env_before_lin=pulse_env_before_lin(idx_keep);
pulse_env_after_lin=pulse_env_after_lin(idx_keep);

%let's remove overlapping targets just in case...
idx_target=zeros(nb_samples,nb_pings);

h = waitbar(0,sprintf('Target %i/%i',1,nb_valid_targets),'Name','Single Targets detection : step 2');
for i=1:nb_valid_targets
    if mod(i,floor(nb_valid_targets/10))==0
        waitbar(i/nb_valid_targets,h,sprintf('Target %i/%i',i,nb_valid_targets));
    end
    idx_same_ping=find(target_ping_number==target_ping_number(i));
    same_target=find((target_range_max(idx_same_ping)==target_range_max(i)&(target_range_min(i)==target_range_min(idx_same_ping))));
    
    if  length(same_target)>=2
        target_TS_comp(idx_same_ping(same_target(2:end)))=nan;
        target_range_max(idx_same_ping(same_target(2:end)))=nan;
        target_range_min(idx_same_ping(same_target(2:end)))=nan;
    end
    
    overlapping_target=(target_range(idx_same_ping)<=target_range_max(i)&(target_range_min(i)<=target_range(idx_same_ping)))|...
        (target_range_max(idx_same_ping)<=target_range_max(i)&(target_range_min(i)<=target_range_max(idx_same_ping)))|...
        (target_range_min(idx_same_ping)<=target_range_max(i)&(target_range_min(i)<=target_range_min(idx_same_ping)));
    
    idx_target(idx_target_lin(i)-pulse_env_before_lin(i):idx_target_lin(i)+pulse_env_after_lin(i))=1;
    
    if nansum(overlapping_target)>=2
        idx_overlap=target_TS_comp(idx_same_ping(overlapping_target))<nanmax(target_TS_comp(idx_same_ping(overlapping_target)));
        target_TS_comp(idx_same_ping(idx_overlap))=nan;
        target_range_max(idx_same_ping(idx_overlap))=nan;
        target_range_min(idx_same_ping(idx_overlap))=nan;
    end
end
close(h);

%removing all non-valid_targets again an storing results in single target
%structure...
idx_keep_final= ~isnan(target_TS_comp);

single_targets.TS_comp=target_TS_comp(idx_keep_final);
single_targets.TS_uncomp=target_TS_uncomp(idx_keep_final);
single_targets.Target_range=target_range(idx_keep_final);
single_targets.Target_range_disp=target_range(idx_keep_final)+dr;
single_targets.idx_r=target_idx_r(idx_keep_final);
single_targets.Target_range_min=target_range_min(idx_keep_final);
single_targets.Target_range_max=target_range_max(idx_keep_final);
single_targets.StandDev_Angles_Minor_Axis=std_along(idx_keep_final);
single_targets.StandDev_Angles_Major_Axis=std_athwart(idx_keep_final);
single_targets.Angle_minor_axis=phi_along(idx_keep_final);
single_targets.Angle_major_axis=phi_athwart(idx_keep_final);
single_targets.Ping_number=target_ping_number(idx_keep_final);
single_targets.Time=target_time(idx_keep_final);
single_targets.nb_valid_targets=nansum(idx_keep_final);
idx_target_lin=idx_target_lin(idx_keep_final)';
single_targets.idx_target_lin=idx_samples_lin(idx_keep_final)';
single_targets.pulse_env_before_lin=pulse_env_before_lin(idx_keep_final)';
single_targets.pulse_env_after_lin=pulse_env_after_lin(idx_keep_final)';
single_targets.PulseLength_Normalized_PLDL=(pulse_env_after_lin(idx_keep_final)'+pulse_env_before_lin(idx_keep_final)'+1)./pulse_length_trans_lin(idx_keep_final)';
single_targets.Transmitted_pulse_length=pulse_length_lin(idx_keep_final)';


heading=Transceiver.AttitudeNavPing.Heading;
pitch=Transceiver.AttitudeNavPing.Pitch;
roll=Transceiver.AttitudeNavPing.Roll;
heave=Transceiver.AttitudeNavPing.Heave;
dist=Transceiver.GPSDataPing.Dist';

if isempty(dist)
    dist=zeros(1,size(TS,2));
end

if isempty(heading)
    heading=zeros(1,size(TS,2));
end

if isempty(roll)
    roll=zeros(1,size(TS,2));
    pitch=zeros(1,size(TS,2));
    heave=zeros(1,size(TS,2));
end

heading_mat=repmat(heading,nb_samples,1);
roll_mat=repmat(roll,nb_samples,1);
pitch_mat=repmat(pitch,nb_samples,1);
heave_mat=repmat(heave,nb_samples,1);
dist_mat=repmat(dist,nb_samples,1);

single_targets.Dist=dist_mat(idx_target_lin);
single_targets.Roll=roll_mat(idx_target_lin);
single_targets.Pitch=pitch_mat(idx_target_lin);
single_targets.Heave=heave_mat(idx_target_lin);
single_targets.Heading=heading_mat(idx_target_lin);

toc;

end

