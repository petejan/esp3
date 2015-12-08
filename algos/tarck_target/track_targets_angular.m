
function tracks_out=track_targets_angular(ST,varargin)

%Parse Arguments
p = inputParser;

defaultAlpha=0.7;
checkAlpha=@(alpha)(alpha>=0&&alpha<=1);
defaultBeta=0.5;
checkBeta=@(beta)(beta>=0&&beta<=1);
defaultExcluDistAxis=2;
defaultExcluDistRange=2;
checkExcluDist=@(e)(e>=0&&e<=50);
checkExcluDistAxis=@(e)(e>=0&&e<=10);
defaultMaxStdAxisAngle=2;
checkMaxStdAxisAngle=@(MaxStdAxisAngle)(MaxStdAxisAngle>=0&&MaxStdAxisAngle<=45);
defaultMissedpingExp=5;
checkMissedPingExp=@(e)(e>=0&&e<=100);
defaultWeightAxis=10;
defaultWeightRange=70;
defaultWeightTS=5;
defaultWeightPingGap=5;
checkWeigt=@(w)(w>=0&&w<=100);
default_min_ST_Track=8;
check_min_ST_track=@(st)(st>=0&&st<=200);
default_Min_Pings_Track=10;
default_Max_Gap_Track=5;
check_accept=@(st)(st>=0&&st<=100);
delta_TS_max=30;

addRequired(p,'ST',@isstruct);
addParameter(p,'AlphaMajAxis',defaultAlpha,checkAlpha);
addParameter(p,'AlphaMinAxis',defaultAlpha,checkAlpha);
addParameter(p,'AlphaRange',defaultAlpha,checkAlpha);
addParameter(p,'BetaMajAxis',defaultBeta,checkBeta);
addParameter(p,'BetaMinAxis',defaultBeta,checkBeta);
addParameter(p,'BetaRange',defaultBeta,checkBeta);
addParameter(p,'ExcluDistMajAxis',defaultExcluDistAxis,checkExcluDistAxis);
addParameter(p,'ExcluDistMinAxis',defaultExcluDistAxis,checkExcluDistAxis);
addParameter(p,'ExcluDistRange',defaultExcluDistRange,checkExcluDist);
addParameter(p,'MaxStdMajorAxisAngle',defaultMaxStdAxisAngle,checkMaxStdAxisAngle);
addParameter(p,'MaxStdMinorAxisAngle',defaultMaxStdAxisAngle,checkMaxStdAxisAngle);
addParameter(p,'MissedPingExpMajAxis',defaultMissedpingExp,checkMissedPingExp);
addParameter(p,'MissedPingExpMinAxis',defaultMissedpingExp,checkMissedPingExp);
addParameter(p,'MissedPingExpRange',defaultMissedpingExp,checkMissedPingExp);
addParameter(p,'WeightMajAxis',defaultWeightAxis,checkWeigt);
addParameter(p,'WeightMinAxis',defaultWeightAxis,checkWeigt);
addParameter(p,'WeightRange',defaultWeightRange,checkWeigt);
addParameter(p,'WeightTS',defaultWeightTS,checkWeigt);
addParameter(p,'WeightPingGap',defaultWeightPingGap,checkWeigt);
addParameter(p,'Min_ST_Track',default_min_ST_Track,check_min_ST_track);
addParameter(p,'Min_Pings_Track',default_Min_Pings_Track,check_accept);
addParameter(p,'Max_Gap_Track',default_Max_Gap_Track,check_accept);

parse(p,ST,varargin{:});



nb_targets=length(ST.TS_comp);
if nb_targets==0
    tracks_out.target_id={};
    tracks_out.target_ping_number={};
    return;
end

idx_tracks=cell(1,nb_targets);
idx_allocation=zeros(1,nb_targets);
tracks_allocation=nan(1,nb_targets);

%Compute target position in each pings (relative to transducer position+dist)
% X_st = zeros(1,nb_targets);
% Y_st = zeros(1,nb_targets);


%Minor is along Major is Across(Athwart)
[X_st,Y_st,Z_st]=angles_to_pos(ST.Target_range,ST.Angle_minor_axis,ST.Angle_major_axis,ST.Heave,ST.Pitch,ST.Roll);
%[X_st,Y_st,Z_st]=angles_to_pos(ST.Target_range,ST.Angle_minor_axis,ST.Angle_major_axis,0,0,0);

%X_st=X_st+ST.Dist;
Z_st=-Z_st;
R_st=-ST.Target_range;


% figure(2);
% hold on;
% scatter3(X_st+ST.Dist,Z_st,Y_st,8,ST.TS_comp,'filled');
% view(2);
% colormap(jet);
% grid on;
% caxis([-65 -45]);

pings=nanmin(ST.Ping_number):nanmax(ST.Ping_number);
nb_pings=length(pings);
nb_targets_pings=zeros(1,nb_pings);
idx_target=cell(1,nb_pings);
active_tracks=cell(1,nb_pings);


X_o=cell(1,nb_pings);Y_o=cell(1,nb_pings);Z_o=cell(1,nb_pings);R_o=cell(1,nb_pings);
X_p=cell(1,nb_pings);Y_p=cell(1,nb_pings);Z_p=cell(1,nb_pings);R_p=cell(1,nb_pings);
X_s=cell(1,nb_pings);Y_s=cell(1,nb_pings);Z_s=cell(1,nb_pings);R_s=cell(1,nb_pings);

VX_o=cell(1,nb_pings);VY_o=cell(1,nb_pings);VZ_o=cell(1,nb_pings);VR_o=cell(1,nb_pings);
VX_p=cell(1,nb_pings);VY_p=cell(1,nb_pings);VZ_p=cell(1,nb_pings);VR_p=cell(1,nb_pings);
VX_s=cell(1,nb_pings);VY_s=cell(1,nb_pings);VZ_s=cell(1,nb_pings);VR_s=cell(1,nb_pings);

current_ping=pings(1);
idx_target{1}=find(ST.Ping_number==current_ping);
nb_targets_pings(1)=length(idx_target{1});
tracks={};
weight={};
tracks_pings={};
for i=1:nb_targets_pings
    tracks{i}=idx_target{1}(i);
    tracks_pings{i}=pings(1);
    weight{i}=0;
    idx_allocation(idx_target{1}(i))=1;
    tracks_allocation(i)=idx_target{1}(i);
end
active_tracks{1}=idx_target{1};


X_init=X_st(idx_target{1});
Y_init=Y_st(idx_target{1});
Z_init=Z_st(idx_target{1});
R_init=R_st(idx_target{1});

X_o{1}=X_init;Y_o{1}=Y_init;Z_o{1}=Z_init;R_o{1}=R_init;
X_p{1}=X_init;Y_p{1}=Y_init;Z_p{1}=Z_init;R_p{1}=R_init;
X_s{1}=X_init;Y_s{1}=Y_init;Z_s{1}=Z_init;R_s{1}=R_init;

VX_o{1}=zeros(1,nb_targets_pings(1));VY_o{1}=zeros(1,nb_targets_pings(1));VZ_o{1}=zeros(1,nb_targets_pings(1));VR_o{1}=zeros(1,nb_targets_pings(1));
VX_p{1}=zeros(1,nb_targets_pings(1));VY_p{1}=zeros(1,nb_targets_pings(1));VZ_p{1}=zeros(1,nb_targets_pings(1));VR_p{1}=zeros(1,nb_targets_pings(1));
VX_s{1}=zeros(1,nb_targets_pings(1));VY_s{1}=zeros(1,nb_targets_pings(1));VZ_s{1}=zeros(1,nb_targets_pings(1));VR_s{1}=zeros(1,nb_targets_pings(1));

h = waitbar(0,sprintf('Ping %i/%i',2,nb_pings),'Name','Processing tracks: Step 1');

for i=2:nb_pings
    if mod(i,floor(nb_pings/10))==0
        waitbar(i/nb_pings,h,sprintf('Ping %i/%i',i,nb_pings));
    end
    current_ping=pings(i);
    idx_target{i}=find(ST.Ping_number==current_ping&idx_allocation==0);
    nb_targets_pings(i)=length(idx_target{i});
    
    X_init=X_st(idx_target{i});
    Y_init=Y_st(idx_target{i});
    Z_init=Z_st(idx_target{i});
    R_init=R_st(idx_target{i});
    
    X_o{i}=X_init;Y_o{i}=Y_init;Z_o{i}=Z_init;R_o{i}=R_init;
    X_s{i}=X_init;Y_s{i}=Y_init;Z_s{i}=Z_init;R_s{i}=R_init;
    
    VX_o{i}=zeros(1,nb_targets_pings(i));VY_o{i}=zeros(1,nb_targets_pings(i));VZ_o{i}=zeros(1,nb_targets_pings(i));VR_o{i}=zeros(1,nb_targets_pings(i));
    VX_s{i}=zeros(1,nb_targets_pings(i));VY_s{i}=zeros(1,nb_targets_pings(i));VZ_s{i}=zeros(1,nb_targets_pings(i));VR_s{i}=zeros(1,nb_targets_pings(i));
    
    if nb_targets_pings(i)>0&&~isempty(X_s{i-1})
        
        X_p{i}=X_s{i-1}+VX_s{i-1}*(pings(i)-pings(i-1));
        Y_p{i}=Y_s{i-1}+VY_s{i-1}*(pings(i)-pings(i-1));
        Z_p{i}=Z_s{i-1}+VZ_s{i-1}*(pings(i)-pings(i-1));
        R_p{i}=R_s{i-1}+VR_s{i-1}*(pings(i)-pings(i-1));
        
        %Here we need to define the volume in the new ping in which to find
        %targets from (X_o,Y_o,Z_o,R_o) to match with (X_p,Y_p,Z_p,R_p).
        %Targets from (X_o,Y_o,Z_o,R_o) with no match starts potential new
        %tracks...
        
        idx_new_target_tot=[];
        u=0;
        %         if nansum(VZ_s{i-1})>0
        %             figure(11);
        %             plot(VZ_s{i-1})
        %             pause;
        %         end
        
        while u<=p.Results.Max_Gap_Track&&(i-1-u)>0
            
            if (nb_targets_pings(i-u)>0&&~isempty(X_s{i-1-u}))
                target_gate=(repmat(X_o{i},nb_targets_pings(i-1-u),1)-repmat(X_p{i-u}',1,nb_targets_pings(i))).^2./((p.Results.ExcluDistMajAxis+repmat(abs(Z_o{i}),nb_targets_pings(i-1-u),1)*tand(p.Results.MaxStdMajorAxisAngle))*(1+u*p.Results.MissedPingExpMajAxis/100)).^2+...
                    (repmat(Y_o{i},nb_targets_pings(i-1-u),1)-repmat(Y_p{i-u}',1,nb_targets_pings(i))).^2./((p.Results.ExcluDistMinAxis+repmat(abs(Z_o{i}),nb_targets_pings(i-1-u),1)*tand(p.Results.MaxStdMinorAxisAngle))*(1+u*p.Results.MissedPingExpMinAxis/100)).^2+...
                    (repmat(Z_o{i},nb_targets_pings(i-1-u),1)-repmat(Z_p{i-u}',1,nb_targets_pings(i))).^2/(p.Results.ExcluDistRange*(1+u*p.Results.MissedPingExpRange/100))^2;
                
                [idx_old_target,idx_new_target]=find(target_gate<1);
                
                if nb_targets_pings(i-1-u)>1
                    idx_new_target=idx_new_target';
                end
                j=0;
                while j<length(idx_new_target)
                    j=j+1;
                    if nansum(idx_new_target(j)==idx_new_target_tot)==0
                        idx_old_track_temp=[];
                        for d=1:length(active_tracks{i-1-u})
                            if ~isempty(find((tracks{active_tracks{i-1-u}(d)}==idx_target{i-u-1}(idx_old_target(j))), 1))
                                idx_old_track_temp=unique([idx_old_track_temp active_tracks{i-1-u}(d)]);
                            end
                        end
                        
                        active_tracks{i}=([active_tracks{i} idx_old_track_temp]);
                        for t=1:length(idx_old_track_temp)
                            if isempty(find(tracks{idx_old_track_temp(t)}==idx_target{i}(idx_new_target(j)), 1))
                                
                                if length(tracks_pings{idx_old_track_temp(t)})>=2
                                    diff_pings=tracks_pings{idx_old_track_temp(t)}(end)-tracks_pings{idx_old_track_temp(t)}(end-1);
                                    diff_TS=(ST.TS_comp(idx_target{i}(idx_new_target(j)))-ST.TS_comp(tracks{idx_old_track_temp(t)}(end-1)));
                                else
                                    diff_pings=0;
                                    diff_TS=0;
                                end
                                
                                curr_weight=p.Results.WeightMajAxis*(X_o{i}(idx_new_target(j))-X_p{i-u}(idx_old_target(j))).^2./((p.Results.ExcluDistMajAxis+Z_o{i}(idx_new_target(j))*tand(p.Results.MaxStdMajorAxisAngle))*(1+u*p.Results.MissedPingExpMajAxis/100)).^2+...
                                    p.Results.WeightMinAxis*(Y_o{i}(idx_new_target(j))-Y_p{i-u}(idx_old_target(j))).^2./((p.Results.ExcluDistMinAxis+Z_o{i}(idx_new_target(j))*tand(p.Results.MaxStdMinorAxisAngle))*(1+u*p.Results.MissedPingExpMinAxis/100)).^2+...
                                    p.Results.WeightRange*(Z_o{i}(idx_new_target(j))-Z_p{i-u}(idx_old_target(j))).^2/(p.Results.ExcluDistRange*(1+u*p.Results.MissedPingExpRange/100))^2+...
                                    p.Results.WeightTS*diff_TS^2/(delta_TS_max)^2+...
                                    p.Results.WeightPingGap*diff_pings^2/p.Results.Max_Gap_Track^2;
                                
                                if idx_allocation(idx_target{i}(idx_new_target(j)))>=1
                                    concurrent_track=tracks_allocation(idx_target{i}(idx_new_target(j)));
                                    track_temp=tracks{concurrent_track};
                                    idx_tar=find(track_temp==idx_new_target(j));
                                    temp_weight=weight{concurrent_track}(idx_tar);
                                    tracks_allocation(idx_target{i}(idx_new_target(j)))=idx_old_track_temp(t);
                                    
                                    if curr_weight<temp_weight
                                        tracks{concurrent_track}(idx_tar)=[];
                                        tracks_pings{concurrent_track}(idx_tar)=[];
                                        weight{concurrent_track}(idx_tar)=[];
                                        
                                        tracks_allocation(idx_target{i}(idx_new_target(j)))=idx_old_track_temp(t);
                                        tracks{idx_old_track_temp(t)}=[tracks{idx_old_track_temp(t)} idx_target{i}(idx_new_target(j))];
                                        tracks_pings{idx_old_track_temp(t)}=[tracks_pings{idx_old_track_temp(t)} pings(i)];
                                        weight{idx_old_track_temp(t)}=[weight{idx_old_track_temp(t)} curr_weight];
                                        
                                        
                                    else
                                        idx_new_target(j)=[];
                                        idx_old_target(j)=[];
                                        j=j-1;
                                    end
                                else
                                    idx_allocation(idx_target{i}(idx_new_target(j)))=idx_allocation(idx_target{i}(idx_new_target(j)))+1;
                                    
                                    tracks_allocation(idx_target{i}(idx_new_target(j)))=idx_old_track_temp(t);
                                    tracks{idx_old_track_temp(t)}=[tracks{idx_old_track_temp(t)} idx_target{i}(idx_new_target(j))];
                                    tracks_pings{idx_old_track_temp(t)}=[tracks_pings{idx_old_track_temp(t)} pings(i)];
                                    weight{idx_old_track_temp(t)}=[weight{idx_old_track_temp(t)} curr_weight];
                                    
                                end
                                
                                
                                
                            end
                        end
                        
                    end
                    
                end
                
                idx_new_target_tot=[idx_new_target_tot idx_new_target()];
                
                if ~isempty(idx_new_target)
                    X_s{i}(idx_new_target)=X_p{i-u}(idx_old_target)+p.Results.AlphaMinAxis*(X_o{i}(idx_new_target)-X_p{i-u}(idx_old_target));
                    Y_s{i}(idx_new_target)=Y_p{i-u}(idx_old_target)+p.Results.AlphaMajAxis*(Y_o{i}(idx_new_target)-Y_p{i-u}(idx_old_target));
                    Z_s{i}(idx_new_target)=Z_p{i-u}(idx_old_target)+p.Results.AlphaRange*(Z_o{i}(idx_new_target)-Z_p{i-u}(idx_old_target));
                    R_s{i}(idx_new_target)=R_p{i-u}(idx_old_target)+p.Results.AlphaRange*(R_o{i}(idx_new_target)-R_p{i-u}(idx_old_target));
                end
                
                VX_p{i}=(X_p{i}-X_s{i-1})/(pings(i)-pings(i-1));
                VY_p{i}=(Y_p{i}-Y_s{i-1})/(pings(i)-pings(i-1));
                VZ_p{i}=(Z_p{i}-Z_s{i-1})/(pings(i)-pings(i-1));
                VR_p{i}=(R_p{i}-R_s{i-1})/(pings(i)-pings(i-1));
                
                if ~isempty(idx_new_target)
                    VX_o{i}(idx_new_target)=(X_o{i}(idx_new_target)-X_p{i-u}(idx_old_target))/(pings(i)-pings(i-1));
                    VY_o{i}(idx_new_target)=(Y_o{i}(idx_new_target)-Y_p{i-u}(idx_old_target))/(pings(i)-pings(i-1));
                    VZ_o{i}(idx_new_target)=(Z_o{i}(idx_new_target)-Z_p{i-u}(idx_old_target))/(pings(i)-pings(i-1));
                    VR_o{i}(idx_new_target)=(R_o{i}(idx_new_target)-R_p{i-u}(idx_old_target));
                    
                    VX_s{i}(idx_new_target)=VX_p{i-u}(idx_old_target)+p.Results.BetaMinAxis*(VX_o{i}(idx_new_target)-VX_p{i-u}(idx_old_target));
                    VY_s{i}(idx_new_target)=VY_p{i-u}(idx_old_target)+p.Results.BetaMajAxis*(VY_o{i}(idx_new_target)-VY_p{i-u}(idx_old_target));
                    VZ_s{i}(idx_new_target)=VZ_p{i-u}(idx_old_target)+p.Results.BetaRange*(VZ_o{i}(idx_new_target)-VZ_p{i-u}(idx_old_target));
                    VR_s{i}(idx_new_target)=VR_p{i-u}(idx_old_target)+p.Results.BetaRange*(VR_o{i}(idx_new_target)-VR_p{i-u}(idx_old_target));
                end
            end
            u=u+1;
        end
        
        
        idx_new_tracks=(1:nb_targets_pings(i));
        idx_new_tracks(idx_new_target_tot)=[];
        
        
        for k=1:length(idx_new_tracks)
            tracks{length(tracks)+1}=idx_target{i}(idx_new_tracks(k));
            tracks_pings{length(tracks_pings)+1}=current_ping;
            weight{length(weight)+1}=0;
            active_tracks{i}=[active_tracks{i} length(tracks)];
            idx_allocation(idx_target{i}(idx_new_tracks(k)))=1;
            idx_tracks{idx_target{i}(idx_new_tracks(k))}=length(tracks);
            tracks_allocation(idx_target{i}(idx_new_tracks(k)))=length(tracks);
        end
    else
        
        X_p{i}=X_init;Y_p{i}=Y_init;Z_p{i}=Z_init;R_p{i}=R_init;
        VX_p{i}=zeros(1,nb_targets_pings(i));VY_p{i}=zeros(1,nb_targets_pings(i));VZ_p{i}=zeros(1,nb_targets_pings(i));VR_p{i}=zeros(1,nb_targets_pings(i));
        
        if nb_targets_pings(i)>0
            idx_new_tracks=(1:nb_targets_pings(i));
            for k=1:length(idx_new_tracks)
                tracks{length(tracks)+1}=idx_target{i}(idx_new_tracks(k));
                tracks_pings{length(tracks_pings)+1}=current_ping;
                weight{length(weight)+1}=0;
                active_tracks{i}=[active_tracks{i} length(tracks)];
                idx_allocation(idx_target{i}(idx_new_tracks(k)))=1;
                tracks_allocation=length(tracks);
            end
        end
    end
    %         figure(12);
    %         clf
    %         scatter3(X_o{i},Y_o{i},Z_o{i},40,'fill')
    %         hold on;
    %         scatter3(X_s{i},Y_s{i},Z_s{i},40,'fill','g')
    %         scatter3(X_p{i},Y_p{i},Z_p{i},40,'fill','r')
    %
    %     view(2)
    % drawnow;
    %
    
end

close(h);

tracks_out.target_id={};
tracks_out.target_ping_number={};

for i=1:length(tracks)
    idx_targets=tracks{i};
    
    if length(idx_targets)>=p.Results.Min_ST_Track&&(nanmax(ST.Ping_number(idx_targets)-nanmin(ST.Ping_number(idx_targets))+1))>=p.Results.Min_Pings_Track
        unique_pings=unique(tracks_pings{i});
        
        for t=1:length(unique_pings)
            idx_target_same_ping=find(tracks_pings{i}==unique_pings(t));
            min_weight=nanmin(weight{i}(idx_target_same_ping));
            idx_remove=idx_target_same_ping(weight{i}(idx_target_same_ping)>min_weight);
            tracks_pings{i}(idx_remove)=[];
            weight{i}(idx_remove)=[];
            tracks{i}(idx_remove)=[];
            idx_targets(idx_remove)=[];
        end
        %idx_good_tracks=[idx_good_tracks i];
        
        tracks_out.target_id{length(tracks_out.target_id)+1}=tracks{i};
        tracks_out.target_ping_number{length(tracks_out.target_ping_number)+1}=tracks_pings{i};
    else
        tracks{i}=[];
        tracks_pings{i}=[];
        weight{i}=[];
    end
end

end