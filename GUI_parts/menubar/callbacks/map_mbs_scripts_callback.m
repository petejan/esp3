function map_mbs_scripts_callback(~,~,hObject_main)
layer=getappdata(hObject_main,'Layer');

if isvalid(layer)
    if ~isempty(layer)
        if ~isempty(layer.PathToFile)
            path=layer.PathToFile;
        else
            path=pwd;
        end
        
    else
        path=pwd;
    end
else
    path=pwd;
end

hfigs=getappdata(hObject_main,'ExternalFigures');
[Filename,PathToFile]= uigetfile( {fullfile(path,'*')}, 'Pick an MBS output file','MultiSelect','on');
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