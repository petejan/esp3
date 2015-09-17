function load_mbs_scripts_callback(~,~,hObject)


[mbs_files,outDir]=get_mbs_from_esp2();

k=0;
for i=1:length(mbs_files)
    mbs(i)=mbs_cl();
    fileName=mbs_files{i};
    mbs(i).readMbsScriptHeaders(fileName);
    if isfield(mbs(i).input,'data')
        k=k+1;
        Summary{k,1}=mbs(i).input.data.title;
        Summary{k,2}=mbs(i).input.data.main_species;
        Summary{k,3}=mbs(i).input.data.voyage;
        Summary{k,4}=mbs(i).input.data.areas;
        Summary{k,5}=mbs(i).input.data.author;
        Summary{k,6}=mbs(i).input.data.MbsId;
        Summary{k,7}=mbs(i).input.data.created;
    end
end
rmdir(outDir,'s');


% Column names and column format
columnname = {'Title','Species','Voyage','Areas','Author','MbsId','Created'};
columnformat = {'char','char','char','char','char','char','char'};

f = figure('Position',[100 100 800 600],'Resize','off','WindowStyle','modal');
% Create the uitable
t = uitable('Parent',f,...
            'Data', Summary,... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...           
            'ColumnEditable', [false false false false false false],...
            'Units','Normalized','Position',[0 0 1 1],...
            'RowName',[]);
set(t,'Units','pixels');
pos_t=get(t','Position');
set(t,'ColumnWidth',{2*pos_t(3)/10, pos_t(3)/10, pos_t(3)/10, pos_t(3)/10, pos_t(3)/10, 2*pos_t(3)/10, 2*pos_t(3)/10})
  
       


end