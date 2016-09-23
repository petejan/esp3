function update_echo_logbook_file(layers_obj,varargin)

p = inputParser;

ver_fmt=@(x) ischar(x);

addRequired(p,'layers_obj',@(obj) isa(obj,'layer_cl'));
addParameter(p,'SurveyName','',ver_fmt);
addParameter(p,'Voyage','',ver_fmt);
addParameter(p,'Filename','',@ischar);
addParameter(p,'SurveyData',survey_data_cl.empty(),@(obj) isa(obj,'survey_data_cl'));
parse(p,layers_obj,varargin{:});

results=p.Results;


pathtofile={};
files_lays={};

for ilay=1:length(layers_obj)
    [path_lay,~]=get_path_files(layers_obj(ilay));
    pathtofile=union(pathtofile,path_lay);
    files_lays=union(files_lays,layers_obj(ilay).Filename);
end

if ~strcmp(p.Results.Filename,'')
    [new_path,~,~]=fileparts(p.Results.Filename);
    pathtofile=union(pathtofile,new_path);
end

for ilay=1:length(pathtofile)
    
    surv_data_struct=load_logbook_to_struct(pathtofile{ilay});
    
    idx_sname=find(~strcmp(surv_data_struct.SurveyName,''),1);
    if ~isempty(idx_sname)
        if ~any(strcmp(p.UsingDefaults,'SurveyName'))
            surv_name=results.SurveyName;
        else
            surv_name=surv_data_struct.SurveyName{idx_sname};
        end
    else
        surv_name=results.SurveyName;
    end
    
    idx_vname=find(~strcmp(surv_data_struct.Voyage,''),1);
    if ~isempty(idx_vname)
        if ~any(strcmp(p.UsingDefaults,'Voyage'))
            voy=results.Voyage;
        else
            voy=surv_data_struct.Voyage{idx_vname};
        end
    else
        voy=results.Voyage;
    end
    
    
    dir_raw=dir(fullfile(pathtofile{ilay},'*.raw'));
    dir_asl=dir(fullfile(pathtofile{ilay},'*A'));
    list_raw=union({dir_raw(:).name},{dir_asl(:).name});
    
    
    docNode = com.mathworks.xml.XMLUtils.createDocument('echo_logbook');
    echo_logbook=docNode.getDocumentElement;
    echo_logbook.setAttribute('version','0.1');
    survey_node = docNode.createElement('survey');
    echo_logbook.appendChild(survey_node);
    
    try
        old_files=intersect(list_raw,surv_data_struct.Filename);
        nb_files=length(old_files);
        
        for i=1:nb_files
            
            f_processed=0;
            file_curr=fullfile(pathtofile{ilay},old_files{i});
            idx_file=find(strcmpi(file_curr,files_lays),1);
            idx_file_xml=find(strcmpi(old_files{i},surv_data_struct.Filename));
            
            if isempty(idx_file)
                for is=idx_file_xml
                    
                    if strcmp(file_curr,p.Results.Filename)
                        survdata_temp=p.Results.SurveyData;
                    else
                        survdata_temp=surv_data_struct.SurvDataObj{is};
                    end
                    start_time=survdata_temp.StartTime;
                    end_time=survdata_temp.EndTime;
                    
                    if isnan(end_time)||(end_time==1)||isnan(start_time)||(start_time==0)
                        [start_time,end_time]=start_end_time_from_file(fullfile(pathtofile{ilay},list_raw{i}));
                        
                    end
                    survdata_temp.Voyage=voy;
                    survdata_temp.SurveyName=surv_name;
                    f_processed=1;
                    lineNode=survdata_temp.surv_data_to_logbook_xml(docNode,list_raw{i},'StartTime',start_time,'EndTime',end_time);
                    survey_node.appendChild(lineNode);
                    
                    if strcmp(file_curr,p.Results.Filename)
                        break;
                    end
                end
                
            else
                [idx_lay,found_lay]=layers_obj.find_layer_idx_files_path(file_curr);
                if found_lay>0
                    for ilay2=idx_lay
                        if strcmp(file_curr,p.Results.Filename)
                            survey_data_temp=p.Results.SurveyData;
                        else
                            survey_data_temp=layers_obj(idx_lay).SurveyData;
                        end
                        
                        [start_file_time,end_file_time]=layers_obj(ilay2).get_time_bound_files();
                        file_lay=layers_obj(ilay2).Filename;
                        ifi=find(strcmp(file_curr,file_lay));
                        
                        if isempty(survey_data_temp)
                            survey_data_temp={[]};
                        end
                        
                        if ~iscell(survey_data_temp)
                            survey_data_temp={survey_data_temp};
                        end
                        
                        for  i_cell=1:length(survey_data_temp)
                            if ~isempty(survey_data_temp{i_cell})
                                survdata_temp=survey_data_temp{i_cell};
                                survdata_temp.Voyage=voy;
                                survdata_temp.SurveyName=surv_name;
                                
                                start_time=survdata_temp.StartTime;
                                end_time=survdata_temp.EndTime;
                                
                                if (end_file_time(ifi)<start_time||start_file_time(ifi)>(end_time))
                                    continue;
                                end
                                
                                if start_time~=0
                                    start_time=nanmax(start_time,start_file_time(ifi));
                                end
                                
                                if end_time~=1
                                    end_time=nanmin(end_time,end_file_time(ifi));
                                end
                                
                                f_processed=1;
                                lineNode=survdata_temp.surv_data_to_logbook_xml(docNode,list_raw{i},'StartTime',start_time,'EndTime',end_time);
                                survey_node.appendChild(lineNode);
                            end
                            
                        end
                        
                        if f_processed==0
                            survdata_temp=survey_data_cl('Voyage',voy,'SurveyName',surv_name);
                            end_time=layers_obj(ilay2).Transceivers(1).Data.Time(end);
                            start_time=layers_obj(ilay2).Transceivers(1).Data.Time(1);
                            f_processed=1;
                            lineNode=survdata_temp.surv_data_to_logbook_xml(docNode,list_raw{i},'StartTime',start_time,'EndTime',end_time);
                            survey_node.appendChild(lineNode);
                        end
                    end
                end
            end
            
            if f_processed==0
                disp('Pb in logbook...')
            end
        end
        
        survey_node.setAttribute('SurveyName',surv_name);
        survey_node.setAttribute('Voyage',voy);
        
        new_files=setdiff(list_raw,surv_data_struct.Filename);
        
        for i=1:length(new_files)
            fprintf('Adding file %s to logbook\n',new_files{i});
            [start_time,end_time]=start_end_time_from_file(fullfile(pathtofile{ilay},new_files{i}));
            
            
            if strcmp(fullfile(pathtofile{ilay},new_files{i}),p.Results.Filename)
                survdata_temp=p.Results.SurveyData;
            else
                survdata_temp=survey_data_cl('Voyage',voy,'SurveyName',surv_name);
            end
            
            lineNode=survdata_temp.surv_data_to_logbook_xml(docNode,new_files{i},'StartTime',start_time,'EndTime',end_time);
            survey_node.appendChild(lineNode);
        end
        
        
        xml_file=fullfile(pathtofile{ilay},'echo_logbook.xml');
        xmlwrite(xml_file,docNode);
        htmlfile=fullfile(pathtofile{ilay},'echo_logbook.html');
        xslt(xml_file, fullfile(whereisEcho,'config','echo_logbook.xsl'), htmlfile);
        
        
    catch err
        disp(err.message);
        warning('Error when updating the logbook') ;
    end
    
end



end