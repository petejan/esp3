function load_mbs_fig(hObject_main,mbsSummary)

% Column names and column format
columnname = {'Title','Species','Voyage','Areas','Author','MbsId','Created'};
columnformat = {'char','char','char','char','char','char','char'};

mbs_figure = figure('Position',[100 100 800 600],'Resize','off');%,'WindowStyle','modal');
% Create the uitable
mbs_table = uitable('Parent',mbs_figure,...
    'Data', mbsSummary,...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'ColumnEditable', [false false false false false false],...
    'Units','Normalized','Position',[0 0 1 1],...
    'RowName',[]);
set(mbs_table,'Units','pixels');
pos_t=get(mbs_table,'Position');
set(mbs_table,'ColumnWidth',{2*pos_t(3)/10, pos_t(3)/10, pos_t(3)/10, pos_t(3)/10, pos_t(3)/10, 2*pos_t(3)/10, 2*pos_t(3)/10});
set(mbs_table,'CellSelectionCallback',{@store_selected_mbs_callback,mbs_figure})

rc_menu = uicontextmenu;
mbs_table.UIContextMenu =rc_menu;
uimenu(rc_menu,'Label','Run','Callback',{@run_mbs_callback,mbs_figure,hObject_main});
uimenu(rc_menu,'Label','Edit','Callback',{@edit_mbs_callback,mbs_figure,hObject_main});
selected_mbs={''};

setappdata(mbs_figure,'SelectedMbs',selected_mbs);
setappdata(mbs_figure,'MBS_table',mbs_table);

end


function run_mbs_callback(~,~,hObject,hObject_main)
selected_mbs=getappdata(hObject,'SelectedMbs');
app_path=getappdata(hObject_main,'App_path');

for i=1:length(selected_mbs)
    try
    curr_mbs=selected_mbs{i};
    if~strcmp(curr_mbs,'')
        [fileNames,outDir]=get_mbs_from_esp2(app_path.cvs_root,'MbsId',curr_mbs,'Rev',[]);
    end
    
    mbs=mbs_cl();
    mbs.readMbsScript(app_path.data_root,fileNames{1});
    rmdir(outDir,'s');
    output_filename=sprintf('mbs_output_%s_%s.txt',mbs.input.data.voyage,strrep(mbs.input.data.title,' ',''));
    mbs.outputFile=fullfile(mbs.crestDir,output_filename);
    
    idx_trans=[];
    mbs.absorbtion=8/1000;
    
    mbs.regionSummary_v2(app_path.cvs_root,idx_trans,'crest');
    mbs.stratumSummary;
    mbs.printOutput;
    catch ME 
        disp(ME.identifier);
        continue;
    end
end


end

function edit_mbs_callback(~,~,hObject,hObject_main)
app_path=getappdata(hObject_main,'App_path');
selected_mbs=getappdata(hObject,'SelectedMbs');
if~strcmp(selected_mbs,'')
    [fileNames,outDir]=get_mbs_from_esp2(app_path.cvs_root,'MbsId',selected_mbs{1},'Rev',[]);
    edit(fileNames{1});
    rmdir(outDir,'s');
end
end

function store_selected_mbs_callback(src,event,hObject)
if size(event.Indices,1)>0
  selected_mbs=src.Data(event.Indices(:,1),6);
else
    selected_mbs={''};
end
setappdata(hObject,'SelectedMbs',selected_mbs);
end

