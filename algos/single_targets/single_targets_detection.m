function single_targets=single_targets_detection(trans_obj,varargin)
%SINGLE_TARGET_DETECTION

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


addRequired(p,'trans_obj',check_trans_cl);
addParameter(p,'SoundSpeed',1500,@isnumeric);
addParameter(p,'Type','sp',@ischar);
addParameter(p,'TS_threshold',defaultTsThr,checkTsThr);
addParameter(p,'PLDL',defaultPLDL,checkPLDL);
addParameter(p,'MinNormPL',defaultMinNormPL,checkNormPL);
addParameter(p,'MaxNormPL',defaultMaxNormPL,checkNormPL);
addParameter(p,'reg_obj',region_cl.empty(),@(x) isa(x,'region_cl'));
addParameter(p,'MaxBeamComp',defaultMaxBeamComp,checkBeamComp);
addParameter(p,'MaxStdMinAxisAngle',defaultMaxStdMinAxisAngle,checkMaxStdMinAxisAngle);
addParameter(p,'MaxStdMajAxisAngle',defaultMaxStdMajAxisAngle,checkMaxStdMajAxisAngle);
addParameter(p,'DataType',trans_obj.Mode,check_data_type);
addParameter(p,'load_bar_comp',[]);

parse(p,trans_obj,varargin{:});

if isempty(p.Results.reg_obj)
    idx_r=1:length(trans_obj.get_transceiver_range());
    idx_pings=1:length(trans_obj.get_transceiver_pings());
    mask=zeros(numel(idx_r),numel(idx_pings));
    reg_obj=region_cl('Idx_r',idx_r,'Idx_pings',idx_pings);
else
    idx_pings=p.Results.reg_obj.Idx_pings;
    idx_r=p.Results.reg_obj.Idx_r;
    mask=~(p.Results.reg_obj.create_mask());
    reg_obj=p.Results.reg_obj;
end

idx_r=idx_r(:);
idx_pings=idx_pings(:)';

Number_tot=trans_obj.get_transceiver_pings();
Range_tot=trans_obj.get_transceiver_range();
nb_samples_tot=length(Range_tot);
nb_pings_tot=length(Number_tot);


max_TS=-10;

trans_obj.rm_tracks();
%Initialize usefule variables

switch p.Results.DataType
    case 'CW'
        TS=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field',p.Results.Type);
        if isempty(TS)
            TS=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','sp');
        end
        
    case 'FM'
        TS=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','sp');
end

if isempty(TS)
    disp('Can''t find single targets with no Sp datagram...');
    single_targets=[];
    return;
end

idx_bad=find(trans_obj.Bottom.Tag==0);
idx_p_inter=intersect(idx_bad,idx_pings);
mask(:,idx_p_inter-idx_pings(1)+1)=1;

idx_bad_data=trans_obj.find_regions_type('Bad Data');

mask_inter=reg_obj.get_mask_from_intersection(trans_obj.Regions(idx_bad_data));

mask(mask_inter>=1)=1;

[nb_samples,nb_pings]=size(TS);

Idx_samples_lin=reshape(1:nb_samples_tot*nb_pings_tot,nb_samples_tot,nb_pings_tot);
Idx_samples_lin=Idx_samples_lin(idx_r,idx_pings);

Bottom=trans_obj.get_bottom_range(idx_pings);

Range=repmat(trans_obj.get_transceiver_range(idx_r),1,nb_pings);

under_bottom=Range>=repmat(Bottom,nb_samples,1);

mask(under_bottom)=1;

TS(mask>=1)=-999;

if ~any(TS(:)>-999)
    single_targets=[];
    return;
end

idx_r_max=find(trans_obj.get_transceiver_range(idx_r)==nanmax(Range(TS>-999)));

%%%%%%%Remove all unnecessary data%%%%%%%%
idx_r(idx_r_max:end)=[];
TS(idx_r_max:end,:)=[];
Idx_samples_lin(idx_r_max:end,:)=[];
[nb_samples,nb_pings]=size(TS);
along=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','AlongAngle');
athwart=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','AcrossAngle');

if isempty(along)||isempty(along)
    disp('Computing using single beam data');
    along=zeros(size(TS));
    athwart=zeros(size(TS));
end

Range=repmat(trans_obj.get_transceiver_range(idx_r),1,nb_pings);
Samples=repmat(idx_r',1,nb_pings);
Ping=repmat(trans_obj.get_transceiver_pings(idx_pings),nb_samples,1);
Time=repmat(trans_obj.get_transceiver_time(idx_pings),nb_samples,1);


[T,Np]=trans_obj.get_pulse_length(1);


Pulse_length_sample=Np*ones(size(TS));

BW_athwart=trans_obj.Config.BeamWidthAthwartship;
BW_along=trans_obj.Config.BeamWidthAlongship;

Pulse_length_max_sample=ceil(Pulse_length_sample.*p.Results.MaxNormPL);
Pulse_length_min_sample=floor(Pulse_length_sample.*p.Results.MinNormPL);

c=p.Results.SoundSpeed;
alpha=trans_obj.Params.Absorption(1);

%Calculate simradBeamCompensation
simradBeamComp = simradBeamCompensation(BW_along, BW_athwart, along, athwart);

idx_comp=simradBeamComp<=p.Results.MaxBeamComp;
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


switch p.Results.DataType
    case 'CW'
        peak_mat=10*log10(filter(ones(floor(Np/2),1)/floor(Np/2),1,10.^(peak_mat/10)));
        peak_mat(TS==-999)=-999;
        idx_peaks=idx_comp;
        
        for i=1:floor(Np/4)+2
            idx_peaks=idx_peaks&(peak_mat>=[nan(i,nb_pings);peak_mat(1:nb_samples-i,:)])&(peak_mat>=[peak_mat(i+1:nb_samples,:);nan(i,nb_pings)]);
        end
        
        diff_idx_peaks=[zeros(1,nb_pings);diff(idx_peaks)];
        idx_peaks=(diff_idx_peaks==1);
        idx_peaks(TS==-999)=0;
        
        idx_peaks_lin = find(idx_peaks);
        
        % idx_peaks=idx_peaks&(peak_mat>=[nan(1,nb_pings);peak_mat(1:nb_samples-1,:)]&peak_mat>=[peak_mat(2:nb_samples,:);nan(1,nb_pings)])...
        %      &idx_comp;
        
        %Level of the local maxima (power dB)...
        
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
        
        load_bar_comp=p.Results.load_bar_comp;
        if ~isempty(p.Results.load_bar_comp)
            set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',nb_targets, 'Value',0);
            load_bar_comp.status_bar.setText('Target Detection Step 1');
        end
        
        for i=1:nb_targets
            if mod(i,floor(nb_targets/10))==0
                if ~isempty(p.Results.load_bar_comp)
                    set(load_bar_comp.progress_bar,'Value',i);
                end
            end
            idx_pulse=idx_target_lin(i)-pulse_env_before_lin(i):idx_target_lin(i)+pulse_env_after_lin(i);
            samples_targets_power(1:pulse_length_lin(i),i)=Power(idx_pulse);
            samples_targets_comp(1:pulse_length_lin(i),i)=simradBeamComp(idx_pulse);
            samples_targets_range(1:pulse_length_lin(i),i)=Range(idx_pulse);
            samples_targets_sample(1:pulse_length_lin(i),i)=Samples(idx_pulse);
            samples_targets_along(1:pulse_length_lin(i),i)=along(idx_pulse);
            samples_targets_athwart(1:pulse_length_lin(i),i)=athwart(idx_pulse);
            target_ping_number(i)=Ping(idx_target_lin(i));
            target_time(i)=Time(idx_target_lin(i));
        end
        
        [target_peak_power,idx_peak_power]=nanmax(samples_targets_power);
        target_comp=samples_targets_comp(idx_peak_power+(0:nb_targets-1)*max_pulse_length);
        samples_targets_idx_r=nanmin(samples_targets_sample)+idx_peak_power-1;
        
        std_along=nanstd(samples_targets_along);
        std_athwart=nanstd(samples_targets_athwart);
        phi_along=nanmean(samples_targets_along);
        phi_athwart=nanmean(samples_targets_athwart);
        
        samples_targets_power(:,std_along>p.Results.MaxStdMinAxisAngle|std_athwart>p.Results.MaxStdMajAxisAngle)=nan;
        samples_targets_range(:,std_along>p.Results.MaxStdMinAxisAngle|std_athwart>p.Results.MaxStdMajAxisAngle)=nan;
        
        
        dr=double(c*T/4);
        target_range=nansum(samples_targets_power.*samples_targets_range)./nansum(samples_targets_power)-dr;
        
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
        
        if ~isempty(p.Results.load_bar_comp)
            set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',nb_valid_targets, 'Value',0);
            load_bar_comp.status_bar.setText('Target Detection Step 2');
        end
        
        for i=1:nb_valid_targets
            if mod(i,floor(nb_valid_targets/10))==0
                if ~isempty(p.Results.load_bar_comp)
                    set(load_bar_comp.progress_bar,'Value',i);
                end
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
        
        
    case 'FM'
        peak_mat=10*log10(filter(ones(floor(Np/2),1)/floor(Np/2),1,10.^(peak_mat/10)));
        idx_peaks=false(size(TS));
                  
        for i=1:size(TS,2)
            [~,tmp]=findpeaks(peak_mat(:,i),'MinPeakDistance',Np);
            idx_peaks(tmp,i)=true;
        end
        idx_samples_lin=Idx_samples_lin(idx_peaks);
        single_targets=[];
        disp('Algorithm not working in FM mode yet');
        return;
end


heading=trans_obj.AttitudeNavPing.Heading;
pitch=trans_obj.AttitudeNavPing.Pitch;
roll=trans_obj.AttitudeNavPing.Roll;
heave=trans_obj.AttitudeNavPing.Heave;
dist=trans_obj.GPSDataPing.Dist';

pitch(isnan(pitch))=0;

roll(isnan(roll))=0;

heave(isnan(heave))=0;

dist(isnan(dist))= 0;


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

heading_mat=repmat(heading(idx_pings),nb_samples,1);
roll_mat=repmat(roll(idx_pings),nb_samples,1);
pitch_mat=repmat(pitch(idx_pings),nb_samples,1);
heave_mat=repmat(heave(idx_pings),nb_samples,1);
dist_mat=repmat(dist(idx_pings),nb_samples,1);

single_targets.Dist=dist_mat(idx_target_lin);
single_targets.Roll=roll_mat(idx_target_lin);
single_targets.Pitch=pitch_mat(idx_target_lin);
single_targets.Heave=heave_mat(idx_target_lin);
single_targets.Heading=heading_mat(idx_target_lin);

%old_single_targets=trans_obj.ST;

% if~isempty(old_single_targets)
%     if ~isempty(old_single_targets.TS_comp)
%
%         idx_rem=(old_single_targets.idx_r>=idx_r(1)&old_single_targets.idx_r<=idx_r(end))&(old_single_targets.Ping_number>=idx_pings(1)&old_single_targets.Ping_number<=idx_pings(end));
%
%         props=fields(old_single_targets);
%
%         for i=1:length(props)
%             if length(old_single_targets.(props{i}))==length(idx_rem)
%             old_single_targets.(props{i})(idx_rem)=[];
%             single_targets.(props{i})=[old_single_targets.(props{i})(:)' single_targets.(props{i})(:)'];
%             end
%         end
%     end
%
%     single_targets.nb_valid_targets=length(single_targets.TS_comp);
% end

