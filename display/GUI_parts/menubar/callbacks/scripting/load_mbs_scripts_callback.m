function load_mbs_scripts_callback(~,~,hObject)

app_path=getappdata(hObject,'App_path');


[mbs_files,outDir]=get_mbs_from_esp2(app_path.cvs_root);

if isempty(mbs_files)
    return;
end
k=0;
for i=1:length(mbs_files)
    mbs(i)=mbs_cl();
    fileName=mbs_files{i};
    mbs(i).readMbsScriptHeaders(fileName);
    k=k+1;
    mbsSummary{k,1}=mbs(i).Header.title;
    mbsSummary{k,2}=mbs(i).Header.main_species;
    mbsSummary{k,3}=mbs(i).Header.voyage;
    mbsSummary{k,4}=mbs(i).Header.areas;
    mbsSummary{k,5}=mbs(i).Header.author;
    mbsSummary{k,6}=mbs(i).Header.MbsId;
    mbsSummary{k,7}=mbs(i).Header.created;

end
rmdir(outDir,'s');

%load_mbs_fig(hObject,mbsSummary)
load_scripts_fig(hObject,mbsSummary,'mbs')

end