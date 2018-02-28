function map_mbs_scripts_callback(~,~,hObject_main)

app_path=getappdata(main_figure,'App_path');


[Filename,PathToFile]= uigetfile( {fullfile(app_path.results,'*')}, 'Pick an MBS output file','MultiSelect','on');
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