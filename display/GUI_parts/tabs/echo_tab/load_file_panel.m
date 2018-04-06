function load_file_panel(main_figure,echo_tab_panel)
app_path=getappdata(main_figure,'App_path');

file_tab_comp.file_tab=new_echo_tab(main_figure,echo_tab_panel,'Title','Files');

pos=getpixelposition(file_tab_comp.file_tab);

%javaComponentName = 'javax.swing.JFileChooser';
javaComponentName = 'com.mathworks.hg.util.dFileChooser';
%javaComponentName='com.mathworks.mwswing.MJFileChooserPerPlatform';
file_tab_comp.FileChooser = handle(javaObjectEDT(javaComponentName),'CallbackProperties');

file_tab_comp.FileChooser.setApproveButtonText(java.lang.String('Open'));
file_tab_comp.FileChooser.setPreferredSize(java.awt.Dimension(pos(3)/2,pos(4)*0.95));
file_tab_comp.FileChooser.setCurrentDirectory(java.io.File(app_path.data));
file_tab_comp.FileChooser.setMultiSelectionEnabled(true);
file_tab_comp.FileChooser.setDragEnabled(true);
globalPanel = javax.swing.JPanel(java.awt.BorderLayout);
[file_tab_comp.JPanel, file_tab_comp.JPanelContainer] = javacomponent(globalPanel, [0 0 pos(3)/2 pos(4)], file_tab_comp.file_tab);
set(file_tab_comp.JPanelContainer,'units','normalized');
file_tab_comp.JPanel.add(file_tab_comp.FileChooser);
file_tab_comp.FileChooser.repaint();
drawnow;

% bgcolor = num2cell(get(main_figure, 'Color'));
% 
% file_tab_comp.FileChooser.setBackground(java.awt.Color(bgcolor{:}));
% file_tab_comp.FileChooser.setForeground(java.awt.Color(bgcolor{:}));
% file_tab_comp.JPanel.setBackground(java.awt.Color(bgcolor{:}));
% file_tab_comp.JPanel.setForeground(java.awt.Color(bgcolor{:}));


filterSpec={'Pick a raw/crest/asl/fcv30/logbook file (*.raw,d*,*A,*.lst,*.db)' {'*.raw';'d*';'*A';'*.lst';'echo_logbook.db'}};

file_tab_comp.FileChooser.setAcceptAllFileFilterUsed(false);
fileFilter = {};

for filterIdx = 1 : size(filterSpec,1)
    fileFilter{end+1} = add_file_filter(file_tab_comp.FileChooser, filterSpec{filterIdx,:}); %#ok<AGROW>
end
try
    file_tab_comp.FileChooser.setFileFilter(fileFilter{1});  % use the first filter by default
catch
    % never mind - ignore...
end

file_tab_comp.FileChooser.PropertyChangeCallback  = {@file_select_cback,main_figure};
file_tab_comp.FileChooser.ActionPerformedCallback = {@button_cbacks,main_figure};


file_tab_comp.map_axes=axes('Parent',file_tab_comp.file_tab,'Units','normalized',...
    'OuterPosition',[0.5 0 0.5 1],'visible','off','NextPlot','add','box','on');

init_map_from_folder(file_tab_comp.map_axes,app_path.data);

file_tab_comp.tracks_plots=plot(file_tab_comp.map_axes,[],[]);

%set(file_tab_comp.file_tab,'SizeChangedFcn',{@resize_file_selector_cback,main_figure});

setappdata(main_figure,'file_tab',file_tab_comp);
end

function init_map_from_folder(ax,folder)

cla(ax);
%legend(ax,'off');
map_info.Proj= [];
map_info.LatLim=[];
map_info.LongLim=[];
survey_data=get_survey_data_from_db(folder);
if isempty(survey_data{1})
    title(ax,'');
else
    title(ax,sprintf('Survey %s, Voyage %s',survey_data{1}{1}.SurveyName,survey_data{1}{1}.Voyage));
end
% gps_data=get_gps_data_from_db(folder);
% if isempty(gps_data)
%     return;
% end
% LongLim=[nanmin(gps_data{1}.Long) nanmax(gps_data{1}.Long)];
% LatLim=[nanmin(gps_data{1}.Lat) nanmax(gps_data{1}.Lat)];
%
% map_info.Proj= init_proj(LongLim,LatLim);
% map_info.LatLim=LatLim;
% map_info.LongLim=LongLim;
% if isempty(map_info.Proj)
%     return;
% end

set(ax,'UserData',map_info);

end

% function resize_file_selector_cback(htab,~,main_figure)
% file_tab_comp=getappdata(main_figure,'file_tab');
% pos=getpixelposition(htab);
% file_tab_comp.JPanel.setPreferredSize(java.awt.Dimension(pos(3)/2,pos(4)*0.95));
% % jColor = java.awt.Color.red;  % or: java.awt.Color(1,0,0)
% % jNewBorder = javax.swing.border.LineBorder(jColor, 1, true);  % red, 1px, rounded=true
% % file_tab_comp.JPanel.setBorder(jNewBorder);
% file_tab_comp.JPanel.repaint();
% end

function file_select_cback(FileChooser, eventData, main_figure)


try
    
    
    switch char(eventData.getPropertyName)
        case 'SelectedFilesChangedProperty'
            file_tab_comp=getappdata(main_figure,'file_tab');
            
            if~isdeployed()
                disp('Map Update');
            end
            map_info=file_tab_comp.map_axes.UserData;
            %             if 1
            %                 u={file_tab_comp.tracks_plots(:).Tag};
            %                 v=cellfun(@char,eventData.getOldValue,'un',0);
            %             end
            %profile on;
            
            %             if isempty(map_info.Proj)
            %                 return;
            %             end
            tmp = FileChooser.getSelectedFiles;
            files=cell(1,numel(tmp));
            
            for i=1:numel(tmp)
                files{i}=char(tmp(i));
            end
            if isempty(files)
                %legend(file_tab_comp.map_axes,'off');
                return;
            end
            
            if ~isempty(file_tab_comp.tracks_plots)
                file_tab_comp.tracks_plots(~isvalid(file_tab_comp.tracks_plots))=[];
            end
            
            if ~isempty(file_tab_comp.tracks_plots)
                idx_rem=~ismember({file_tab_comp.tracks_plots(:).Tag},files);
                delete(file_tab_comp.tracks_plots(idx_rem));
                file_tab_comp.tracks_plots(idx_rem)=[];
                [~,idx_new]=setdiff(files,{file_tab_comp.tracks_plots(:).Tag});
                files=files(idx_new);
            end
            
            file_old=cell(1,numel(file_tab_comp.tracks_plots));
            gps_data_old=cell(1,numel(file_tab_comp.tracks_plots));
            txt_old=cell(1,numel(file_tab_comp.tracks_plots));
            
            for iold=1:numel(file_tab_comp.tracks_plots)
                gps_data_old{iold}=file_tab_comp.tracks_plots(iold).UserData.gps;
                file_old{iold}=file_tab_comp.tracks_plots(iold).UserData.file;
                txt_old{iold}=file_tab_comp.tracks_plots(iold).UserData.txt;
            end
            
            [~,idx_keep]=unique(file_old);
            
            txt_old=txt_old(idx_keep);
            file_old=file_old(idx_keep);
            gps_data_old=gps_data_old(idx_keep);

            
            delete(file_tab_comp.tracks_plots);
            file_tab_comp.tracks_plots=[];
                      
            cla(file_tab_comp.map_axes);
            
            survey_data=get_survey_data_from_db(files);
            idx_rem=cellfun(@numel,survey_data)==0;
            files(idx_rem)=[];
            survey_data(idx_rem)=[];
            if ~isempty(files)
                gps_data=get_ping_data_from_db(files);
            else
                gps_data={};
            end
            txt=cell(1,numel(files));
            
            for ifi=1:numel(files)
                if ~isempty(gps_data{ifi})
                    [~,text_str,ext_str]=fileparts(files{ifi});
                    text_str=[text_str ext_str ' '];
                    for is=1:length(survey_data{ifi})
                        text_str=[text_str survey_data{ifi}{is}.print_survey_data ' '];
                    end
                     txt{ifi}=text_str;
                else
                    
                    
                end
            end
            
            gps_data=[gps_data gps_data_old];
            txt=[txt txt_old];
            files=[files file_old];

            if all(cellfun(@isempty,gps_data))
                %legend(file_tab_comp.map_axes,'off');
                return;
            end
            
            
            LatLim=[inf -inf];
            LongLim=[inf -inf];
            
            for ifi=1:numel(files)
                if ~isempty(gps_data{ifi})
                    LongLim(1)=nanmin(LongLim(1),nanmin(gps_data{ifi}.Long));
                    LongLim(2)=nanmax(LongLim(2),nanmax(gps_data{ifi}.Long));
                    LatLim(1)=nanmin(LatLim(1),nanmin(gps_data{ifi}.Lat));
                    LatLim(2)=nanmax(LatLim(2),nanmax(gps_data{ifi}.Lat));
                end
            end
             map_info.Proj= init_proj('Mercator',LongLim,LatLim);   
            [LatLim,LongLim]=ext_lat_lon_lim(LatLim,LongLim,0.3);
            map_info.Proj= init_proj('Mercator',LongLim,LatLim);
            map_info.LatLim=LatLim;
            map_info.LongLim=LongLim;
            
            if isempty(map_info.Proj)
                return;
            end
            
            set(file_tab_comp.map_axes,'UserData',map_info);

            % m_proj(map_info.Proj,'long',map_info.LongLim,'lat',map_info.LatLim);
    
            for ifi=1:numel(files)
                if ~isempty(gps_data{ifi})
                    userdata.txt=txt{ifi};
                    userdata.gps=gps_data{ifi};
                    userdata.file=files{ifi};
                    
                    file_tab_comp.tracks_plots=[file_tab_comp.tracks_plots ...
                        m_plot(file_tab_comp.map_axes,gps_data{ifi}.Long(1),gps_data{ifi}.Lat(1),'Marker','o','Tag',files{ifi},'Color',[0 0.6 0],'UserData',userdata,'Markersize',6,'LineWidth',2,'MarkerFaceColor',[0 0.6 0]) ...
                        m_plot(file_tab_comp.map_axes,gps_data{ifi}.Long,gps_data{ifi}.Lat,'Tag',files{ifi},'UserData',userdata,'ButtonDownFcn',@disp_file_name_callback,'linewidth',2)] ;
                    enterFcn =  @(figHandle, currentPoint)...
                        set(figHandle, 'Pointer', 'hand');
                    iptSetPointerBehavior(file_tab_comp.tracks_plots,enterFcn);

                else
                  
                end
            end

            try
                set(file_tab_comp.map_axes,'visible','on')
                m_grid('tickdir','in','axes',file_tab_comp.map_axes);
                
            catch
                set(file_tab_comp.map_axes,'visible','off')
                warning('area too small for ticks to display')
            end
                       

            %profile off;
            %profile viewer;
            setappdata(main_figure,'file_tab',file_tab_comp);
        case 'directoryChanged'
            file_tab_comp=getappdata(main_figure,'file_tab');
            
            init_map_from_folder(file_tab_comp.map_axes,char(eventData.getNewValue));
            setappdata(main_figure,'file_tab',file_tab_comp);
        otherwise
            if~isdeployed()
                disp(eventData.getPropertyName);
            end
    end
    
catch err
    if ~isdeployed()
        disp('Error in file tab')
        rethrow(err);
    end
    % Never mind - bail out...
end

end

function disp_file_name_callback(src,~)

ax=get(src,'parent');
hfig=ancestor(ax,'Figure');

cp=ax.CurrentPoint;
x = cp(1,1);
y=cp(1,2);

switch hfig.SelectionType
    case 'normal'
        str=src.UserData.txt;
        u = findobj(ax,'Tag','name');
        delete(u);
       
        text(x,y,str,'Interpreter','None','Tag','name','parent',ax,'Tag','name');
        
end
end

function fileFilter = add_file_filter(FileChooser, description, extension)
try
    if ~iscell(extension)
        extension = {extension};
    end
    
    if strcmp(extension{1},'*.*')
        jBasicFileChooserUI = javax.swing.plaf.basic.BasicFileChooserUI(FileChooser.java);
        fileFilter = javaObjectEDT('javax.swing.plaf.basic.BasicFileChooserUI$AcceptAllFileFilter',jBasicFileChooserUI);
    else
        extension = regexprep(extension,'^.*\*?\.','');
        fileFilter = com.mathworks.mwswing.FileExtensionFilter(description, extension, false, true);
    end
    javaMethodEDT('addChoosableFileFilter',FileChooser,fileFilter);
catch
    fileFilter = [];
end
end

function button_cbacks(FileChooser, eventData, main_figure)
switch char(eventData.getActionCommand)
    case 'CancelSelection'
        
    case 'ApproveSelection'
        files = cellfun(@char, cell(FileChooser.getSelectedFiles), 'uniform',0);
        
        if isempty(files)
            files = char(FileChooser.getSelectedFile);
        end
        open_file([],[],files,main_figure)
        
    otherwise
        % should never happen
end
end  % button_cbacks