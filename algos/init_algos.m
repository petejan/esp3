function algo_vec=init_algos(name)

name_vec={'BottomDetection','BadPings','Denoise','SchoolDetection','SingleTarget','TrackTarget'};
algo_vec=[];

if nargin==0
    name=name_vec;
end

if nansum(strcmpi(name,'BottomDetection'))>0
    algo_vec=[algo_vec algo_cl('Name','BottomDetection')];
end
if nansum(strcmpi(name,'BadPings'))>0
    algo_vec=[algo_vec algo_cl('Name','BadPings')];
end
if nansum(strcmpi(name,'Denoise'))>0
    algo_vec=[algo_vec algo_cl('Name','Denoise')];
end
if nansum(strcmpi(name,'SchoolDetection'))>0
    algo_vec=[algo_vec algo_cl('Name','SchoolDetection')];
end
if nansum(strcmpi(name,'SingleTarget'))>0
    algo_vec=[algo_vec algo_cl('Name','SingleTarget')];
end
if nansum(strcmpi(name,'TrackTarget'))>0
    algo_vec=[algo_vec algo_cl('Name','TrackTarget')];
end

end