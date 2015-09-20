function load_mbs_scripts_callback(~,~,hObject)

app_path=getappdata(hObject,'App_path');

[mbs_files,outDir]=get_mbs_from_esp2(app_path.cvs_root);

k=0;
for i=1:length(mbs_files)
    mbs(i)=mbs_cl();
    fileName=mbs_files{i};
    mbs(i).readMbsScriptHeaders(fileName);
    if isfield(mbs(i).input,'data')
        k=k+1;
        mbsSummary{k,1}=mbs(i).input.data.title;
        mbsSummary{k,2}=mbs(i).input.data.main_species;
        mbsSummary{k,3}=mbs(i).input.data.voyage;
        mbsSummary{k,4}=mbs(i).input.data.areas;
        mbsSummary{k,5}=mbs(i).input.data.author;
        mbsSummary{k,6}=mbs(i).input.data.MbsId;
        mbsSummary{k,7}=mbs(i).input.data.created;
    end
end
rmdir(outDir,'s');

load_mbs_fig(hObject,mbsSummary)

       


end