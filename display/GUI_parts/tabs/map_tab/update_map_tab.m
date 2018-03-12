function update_map_tab(main_figure,varargin)
if ~isdeployed()
    disp('Updating Map tab')
end

p = inputParser;
addRequired(p,'main_figure',@(obj) isa(obj,'matlab.ui.Figure'));
addParameter(p,'src',[],@(obj) isempty(obj)|ishandle(obj));

parse(p,main_figure,varargin{:});
src=p.Results.src;
up_plots=0;
up_coast=0;
up_cont=0;
try
    if ~isempty(src)
        map_tab_comp=getappdata(main_figure,'Map_tab');
        switch src.Style
            case 'edit'
                check_fmt_box(src,[],0,10000,500,'%.0f');
                if map_tab_comp.cont_disp>0&& map_tab_comp.cont_val~=str2double(map_tab_comp.contour_edit_box.String)
                    up_cont=1;
                end
        end
        
        map_tab_comp.cont_disp=map_tab_comp.cont_checkbox.Value;
        map_tab_comp.coast_disp=map_tab_comp.coast_checkbox.Value;
        map_tab_comp.cont_val=str2double(map_tab_comp.contour_edit_box.String);
        map_tab_comp.all_lays=map_tab_comp.rad_all.Value;
        
        switch src
            case map_tab_comp.cont_checkbox
                
                if isempty(map_tab_comp.contour_plots)
                    up_cont=1;
                else
                    map_tab_comp.h_contour_plots(~isvalid(map_tab_comp.h_contour_plots))=[];
                    
                    if map_tab_comp.cont_disp>0
                        set(map_tab_comp.h_contour_plots,'visible','on');
                    else
                        set(map_tab_comp.h_contour_plots,'visible','off');
                    end
                end
            case map_tab_comp.coast_checkbox
                if isempty(map_tab_comp.h_coast_plot)
                    up_coast=1;
                else
                    
                    map_tab_comp.h_coast_plot(~isvalid(map_tab_comp.h_coast_plot))=[];
                    if map_tab_comp.coast_disp>0
                        set(map_tab_comp.h_coast_plot,'visible','on');
                    else
                        set(map_tab_comp.h_coast_plot,'visible','off');
                    end
                end
            case {map_tab_comp.rad_all  map_tab_comp.rad_curr}
                up_plots=1;
        end
        
        setappdata(main_figure,'Map_tab',map_tab_comp);
        
        if up_plots==0&&up_coast==0&&up_cont==0
            return;
        end
    else
        up_plots=1;
        up_coast=0;
        up_cont=0;
    end
    
    map_tab_comp=getappdata(main_figure,'Map_tab');
    
    if up_plots>0
        if isempty(map_tab_comp.idx_lays)
            if map_tab_comp.all_lays
                layers=getappdata(main_figure,'Layers');
            else
                layers=getappdata(main_figure,'Layer');
            end
        else
            layers_tmp=getappdata(main_figure,'Layers');
            layers=layers_tmp(idx_lays);
        end
        replot=0;
        if isempty(layers)
            files={};
        else
            files=layers.list_files_layers();
        end
        
        if ~isempty(map_tab_comp.tracks_plots)
            map_tab_comp.tracks_plots(~isvalid(map_tab_comp.tracks_plots))=[];
        end
        
        if ~isempty(map_tab_comp.tracks_plots)
            idx_rem=~ismember({map_tab_comp.tracks_plots(:).Tag},files);
            if any(idx_rem)
                replot=1;
                up_coast=1;
                up_cont=1;
            end
            delete(map_tab_comp.tracks_plots(idx_rem));
            map_tab_comp.tracks_plots(idx_rem)=[];
            [~,idx_new]=setdiff(files,{map_tab_comp.tracks_plots(:).Tag});
            if ~isempty(idx_new)
                replot=1;
                up_coast=1;
                up_cont=1;
            end
            files=files(idx_new);
        end
        
        if ~isempty(files)||replot
            up_coast=1;
            up_cont=1;
            file_old=cell(1,numel(map_tab_comp.tracks_plots));
            gps_data_old=cell(1,numel(map_tab_comp.tracks_plots));
            txt_old=cell(1,numel(map_tab_comp.tracks_plots));
            
            for iold=1:numel(map_tab_comp.tracks_plots)
                gps_data_old{iold}=map_tab_comp.tracks_plots(iold).UserData.gps;
                file_old{iold}=map_tab_comp.tracks_plots(iold).UserData.file;
                txt_old{iold}=map_tab_comp.tracks_plots(iold).UserData.txt;
            end
            [~,idx_keep]=unique(file_old);
            
            txt_old=txt_old(idx_keep);
            file_old=file_old(idx_keep);
            gps_data_old=gps_data_old(idx_keep);
            
            delete(map_tab_comp.tracks_plots);
            map_tab_comp.tracks_plots=[];
            
            cla(map_tab_comp.ax);
            delete(map_tab_comp.h_coast_plot);
            map_tab_comp.coast_plot=[];
            map_tab_comp.h_coast_plot=[];
            delete(map_tab_comp.h_coast_plot);
            map_tab_comp.coast_plot=[];
            map_tab_comp.h_coast_plot=[];
            
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
                end
            end
            
            gps_data=[gps_data gps_data_old];
            txt=[txt txt_old];
            files=[files file_old];
            
            if all(cellfun(@isempty,gps_data))
                setappdata(main_figure,'Map_tab',map_tab_comp);
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
            [LatLim,LongLim]=ext_lat_lon_lim(LatLim,LongLim,0.1);
            map_info.Proj= init_proj('Mercator',LongLim,LatLim);
            map_info.LatLim=LatLim;
            map_info.LongLim=LongLim;
            
            if isempty(map_info.Proj)
                setappdata(main_figure,'Map_tab',map_tab_comp);
                return;
            end
            
            map_tab_comp.map_info=map_info;
            set(map_tab_comp.ax,'UserData',map_info);
            
            
            for ifi=1:numel(files)
                if ~isempty(gps_data{ifi})
                    userdata.txt=txt{ifi};
                    userdata.gps=gps_data{ifi};
                    userdata.file=files{ifi};
                    
                    map_tab_comp.tracks_plots=[map_tab_comp.tracks_plots ...
                        m_plot(map_tab_comp.ax,gps_data{ifi}.Long(1),gps_data{ifi}.Lat(1),'Marker','o','Tag',files{ifi},'Color',[0 0.6 0],'UserData',userdata,'Markersize',6,'LineWidth',2,'MarkerFaceColor',[0 0.6 0]) ...
                        m_plot(map_tab_comp.ax,gps_data{ifi}.Long,gps_data{ifi}.Lat,'Tag',files{ifi},'UserData',userdata,'ButtonDownFcn',@disp_file_name_callback,'LineWidth',2)] ;
                    
                    enterFcn =  @(figHandle, currentPoint)...
                        set(figHandle, 'Pointer', 'hand');
                    iptSetPointerBehavior(map_tab_comp.tracks_plots,enterFcn);
                end
            end
            try
                switch get(map_tab_comp.ax,'visible')
                    case 'off'
                        set(map_tab_comp.ax,'visible','on')
                end
                m_grid('tickdir','in','axes',map_tab_comp.ax);
            catch
                set(map_tab_comp.ax,'visible','off')
                warning('area too small for ticks to display')
            end
        end
    end
    
    
    if map_tab_comp.cont_disp>0&&up_cont
        %delete(map_tab_comp.contour_plots);
        delete(map_tab_comp.h_contour_plots);
        map_tab_comp.contour_plots=[];
        map_tab_comp.h_contour_plots=[];
        try
            [lat_c,lon_c,bathy]=get_etopo1(map_tab_comp.map_info.LatLim,map_tab_comp.map_info.LongLim);
            if length(lon_c)>=2&&length(lat_c)>=2
                [map_tab_comp.contour_plots,map_tab_comp.h_contour_plots]=m_contour(lon_c,lat_c,bathy,-10000:map_tab_comp.cont_val:0,...
                    'edgecolor',[.6 .6 .6],'visible','on','parent',map_tab_comp.ax);
                clabel(map_tab_comp.contour_plots,map_tab_comp.h_contour_plots,'fontsize',8,'color',[0.6 0.6 0.6]);
                uistack(map_tab_comp.h_contour_plots,'bottom');
            end
        catch
            disp('Cannot find Etopo1 data...')
        end
    end
    
    if map_tab_comp.coast_disp>0&&up_coast
        %delete(map_tab_comp.coast_plot);
        delete(map_tab_comp.h_coast_plot);
        map_tab_comp.coast_plot=[];
        map_tab_comp.h_coast_plot=[];
        try
            if ~exist('lat_c','var')
                [lat_c,lon_c,bathy]=get_etopo1(map_tab_comp.map_info.LatLim,map_tab_comp.map_info.LongLim);
            end
            
            if length(lon_c)>=2&&length(lat_c)>=2
                [map_tab_comp.coast_plot,map_tab_comp.h_coast_plot]=m_contour(lon_c,lat_c,bathy,0:1000:10000,...
                    'facecolor',[0.8 0.8 0.8],'visible','on','parent',map_tab_comp.ax,'color',[0.8 0 0],'LineWidth',1,'Fill','on');
                uistack(map_tab_comp.h_coast_plot,'bottom');
                %clabel(map_tab_comp.coast_plot,map_tab_comp.h_coast_plot,'fontsize',8);
            end
            
        catch
            disp('No Geographical data available...')
        end
    end
    

   
    
    setappdata(main_figure,'Map_tab',map_tab_comp);
    
    display_info_ButtonMotionFcn([],[],main_figure,1);
catch err
    warning('Error updating map tab: %s',err.message);
    [~,f_temp,e_temp]=fileparts(err.stack(1).file);
    fprintf('Error in file %s, line %d\n',[f_temp e_temp],err.stack(1).line);
    
end
if ~isdeployed()
    disp('Done')
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