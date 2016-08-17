function algo_vec=init_algos(name)

name_vec={'BottomDetection','BadPings','Denoise','SchoolDetection','SingleTarget','TrackTarget'};
algo_vec=[];

if nargin==0
    name=name_vec;
end

if any(strcmpi(name,'BottomDetection'))
    algo_vec=[algo_vec algo_cl('Name','BottomDetection')];
end
if any(strcmpi(name,'BadPings'))
    algo_vec=[algo_vec algo_cl('Name','BadPings')];
end
if any(strcmpi(name,'Denoise'))
    algo_vec=[algo_vec algo_cl('Name','Denoise')];
end
if any(strcmpi(name,'SchoolDetection'))
    algo_vec=[algo_vec algo_cl('Name','SchoolDetection')];
end
if any(strcmpi(name,'SingleTarget'))
    algo_vec=[algo_vec algo_cl('Name','SingleTarget')];
end
if any(strcmpi(name,'TrackTarget'))
    algo_vec=[algo_vec algo_cl('Name','TrackTarget')];
end

end