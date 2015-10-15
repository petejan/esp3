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
        hfig=figure();
        hold on;
        nb_row=ceil(length(mbs_vec)/3);
        nb_col=nanmin(length(mbs_vec),3);
        for i=1:length(mbs_vec)
            figure(hfig);
            ax(i)= subplot(nb_row,nb_col,i);
            mbs_vec(i).display_mbs_results_map(ax(i));
        end
    else
        return;
    end
else
    return;
end

hfigs_new=[hfigs hfig];
setappdata(hObject_main,'ExternalFigures',hfigs_new);

end