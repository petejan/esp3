function algo_vec=init_algos(name)

name_vec={'BottomDetectionV2','BottomDetection','BadPings','Denoise','SchoolDetection','SingleTarget','TrackTarget'};

if nargin==0
    name=name_vec;
end

if~iscell(name)
    name={name};
end
algo_vec(length(name))=algo_cl();

for i=1:length(name)
    algo_vec(i)=algo_cl('Name',name{i});
end

end