function map_mbs_scripts_callback(~,~,hObject_main)
layer=getappdata(hObject_main,'Layer');


if ~isempty(layer)
    if ~isempty(layer(1).Filename)
        [path_f,~,~]=fileparts(layer.Filename{1});
    else
        path_f=pwd;
    end
    
else
    path_f=pwd;
end


[Filename,PathToFile]= uigetfile( {fullfile(path_f,'*')}, 'Pick an MBS output file','MultiSelect','on');
if ~isequal(Filename, 0)
    if ~iscell(Filename)
        Filename={Filename};
    end
    
    mbs_vec=[];
    for i=1:length(Filename)
        mbs=load_mbs_results(fullfile(PathToFile,Filename{i}));
        mbs_vec=[mbs mbs_vec];
    end
    
    if ~isempty(mbs_vec)
       load_map_fig(hObject_main,mbs_vec);
    else
        return;
    end
else
    return;
end

end