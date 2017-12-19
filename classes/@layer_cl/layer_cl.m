
classdef layer_cl < handle
    properties
        Unique_ID=generate_Unique_ID();
        Filename={''};
        ChannelID={''};
        Filetype='';
        Transceivers=transceiver_cl.empty();
        OriginCrest='';
        Lines=line_cl.empty();
        Frequencies=[];
        GPSData=gps_data_cl();
        AttitudeNav=attitude_nav_cl();
        EnvData=env_data_cl();
        Curves=[];
        SurveyData=survey_data_cl();

    end
    
    
    methods
        function obj = layer_cl(varargin)
            p = inputParser;
            
            
            check_att_class=@(obj) isa(obj,'attitude_nav_cl');
            check_gps_class=@(gps_data_obj) isa(gps_data_obj,'gps_data_cl');
            check_curve_cl=@(curve_obj) isempty(curve_obj)|isa(curve_obj,'curve_cl');
            check_env_class=@(env_data_obj) isa(env_data_obj,'env_data_cl')|isempty(env_data_obj);
            check_transceiver_class=@(transceiver_obj) isa(transceiver_obj,'transceiver_cl')|isempty(transceiver_obj);
            check_line_class=@(obj) isa(obj,'line_cl')|isempty(obj);
            
            addParameter(p,'Unique_ID',generate_Unique_ID(),@ischar);
            addParameter(p,'Filename',{'No Data'},@(fname)(iscell(fname)));
            addParameter(p,'Filetype','',@(ftype)(ischar(ftype)));
            addParameter(p,'Transceivers',transceiver_cl.empty(),check_transceiver_class);
            addParameter(p,'Lines',[],check_line_class);
            addParameter(p,'Frequencies',[],@isnumeric);
            addParameter(p,'ChannelID',{},@iscell);
            addParameter(p,'GPSData',gps_data_cl(),check_gps_class);
            addParameter(p,'Curves',[],check_curve_cl);
            addParameter(p,'AttitudeNav',attitude_nav_cl(),check_att_class);
            addParameter(p,'EnvData',env_data_cl(),check_env_class);
            addParameter(p,'OriginCrest','');
            addParameter(p,'SurveyData',{survey_data_cl()},@(obj) isa(obj,'survey_data_cl')|iscell(obj)|isempty(obj))
            
            parse(p,varargin{:});
            results=p.Results;

                       
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
            
            if ~iscell(obj.Filename)
                obj.Filename={obj.Filename};
            end
            
            
            obj.Frequencies=zeros(1,length(obj.Transceivers));
            obj.ChannelID=cell(1,length(obj.Transceivers));
            for ifr=1:length(obj.Transceivers)
                obj.Frequencies(ifr)=obj.Transceivers(ifr).Config.Frequency;
                obj.ChannelID{ifr}=obj.Transceivers(ifr).Config.ChannelID;
            end 
        end
        
        function regenerate_ID_num(layer_obj)
            layer_obj.Unique_ID=generate_Unique_ID();
        end
        
        function fLim=get_flim(layer)
           fmin=+inf;
           fmax=-Inf;
           
           for it=1:length(layer.Frequencies)
               fmin=min(fmin,layer.Transceivers(it).Config.FrequencyMinimum);
               fmax=max(fmax,layer.Transceivers(it).Config.FrequencyMaximum);
           end
            fLim=[fmin fmax];
        end
        
        function reg_uid=get_layer_reg_uid(layer)
            reg_uid={};
            for it=1:length(layer.Frequencies)
                    reg_uid=union(reg_uid,layer.Transceivers(it).get_reg_Unique_IDs());
            end
        end
        
        function rm_memaps(layer)
            
            for kk=1:length(layer.Transceivers)
                for uu=1:length(layer.Transceivers(kk).Data.SubData)
                    layer.Transceivers(kk).Data.remove_sub_data();
                end
                
            end
        end
        
        function rm_trans(layer,cid)
            if ~iscell(cid)
                cid={cid};
            end
            idx_rem=[];
            for kk=1:length(layer.Transceivers)
                if ismember(layer.ChannelID{kk},cid)||isempty(cid)
                    for uu=1:length(layer.Transceivers(kk).Data.SubData)
                        layer.Transceivers(kk).Data.remove_sub_data();
                    end
                    idx_rem=union(idx_rem.kk);
                end
            end
            layer.Transceivers(idx_rem)=[];
            layer.Frequencies(idx_rem)=[];
            layer.ChannelID(idx_rem)=[];
        end
        
        function add_trans(layer,trans_obj)
            layer.rm_trans(trans_obj.Config.ChannelID);
            freq=trans_obj.Config.Frequency;
            cid=trans_obj.Config.ChannelID;

            new_freq=[layer.Frequencies,freq];
            new_cid=[layer.ChannelID cid];
            layer.Transceivers=[layer.Transceivers trans_obj];
            
            [~,idx_order]=sort(new_freq);            
            layer.Transceivers=layer.Transceivers(idx_order);
            layer.Frequencies=new_freq(idx_order);
            layer.ChannelID=new_cid(idx_order);
        end
        
        
        function line_obj=get_first_line(layer_obj)
            if ~isempty(layer_obj.Lines)
                line_obj=layer_obj.Lines(1);
            else          
                line_obj=[];
            end
        end
        
        function [trans_obj,idx_cid]=get_trans(layer,curr_disp)
            trans_obj=[];
            idx_cid=[];
            switch class(curr_disp)
                case {'struct' 'curr_state_disp_cl'}
                    [idx_cid,found]=layer.find_cid_idx(curr_disp.ChannelID);
                    
                    if found==1
                        trans_obj=layer.Transceivers(idx_cid);
                    else
                        [idx_cid,found]=layer.find_freq_idx(curr_disp.Freq);

                        if found==1
                            trans_obj=layer.Transceivers(idx_cid);
                        else
                            trans_obj=[];
                            idx_cid=[];
                        end
                    end
                case 'char'
                    [idx_cid,found]=layer.find_cid_idx(curr_disp);
                    if found==1
                        trans_obj=layer.Transceivers(idx_cid);
                    else
                        trans_obj=[];
                        idx_cid=[];
                    end
                case {'double' 'single' 'int16' 'int8'}
                    [idx_cid,found]=layer.find_freq_idx(curr_disp);                  
                    if found==1
                        trans_obj=layer.Transceivers(idx_cid);
                    else
                        trans_obj=[];
                        idx_cid=[];
                    end
            end
        end
            
        
        function fold_lay=get_folder(layer)
            [folders,~,~]=cellfun(@fileparts,layer.Filename,'UniformOutput',0);
            
            fold_lay=unique(folders);
            
            if length(fold_lay)>1
                warning('Files from multiple folder in one layer...') ;
            end
            
        end
        
        function memap_files=list_memaps(layers)
            memap_files={};
            ifile=0;
            for ilay=1:length(layers)
                for itr=1:length(layers(ilay).Transceivers)
                    for i_sub_data=1:length(layers(ilay).Transceivers(itr).Data.SubData)
                        for imap=1:length(layers(ilay).Transceivers(itr).Data.SubData(i_sub_data).Memap)
                            ifile=ifile+1;
                            memap_files{ifile}=layers(ilay).Transceivers(itr).Data.SubData(i_sub_data).Memap{imap}.Filename;
                        end
                    end
                end
            end
        end
        
        
        function rm_region_across_id(layer,ID)
            for i=1:length(layer.Transceivers)
                layer.Transceivers(i).rm_region_id(ID);
            end
        end
        
        
        function list=list_lines(obj)
            if isempty(obj.Lines)
                list={};
            else
                list=cell(1,length(obj.Lines));
                for i=1:length(obj.Lines)
                    [~,name,ext]=fileparts(obj.Lines(i).File_origin{1});
                    list{i}=sprintf('%s %s',obj.Lines(i).Name,[name ext]);
                end
            end
        end
        
        function rm_line_id(obj,unique_ID)
            lines_curr=obj.Lines;
            lines_new=[];
            for i=1:length(lines_curr)
                if lines_curr(i).ID~=unique_ID;
                    lines_new=[lines_new lines_curr(i)];
                end
            end
            obj.Lines=lines_new;
        end
        
        function add_lines(obj,lines)
            for i=1:length(lines)
                obj.rm_line_id(lines(i).ID);
                if ~isempty(lines(i).Range)
                    obj.Lines=[obj.Lines lines(i)];
                end
            end
        end
        
        function add_curves(obj,curves)
            for i=1:length(curves)
                obj.rm_curves_per_ID_and_type(curves(i).Unique_ID,curves(i).Type);
                obj.Curves=[obj.Curves curves(i)];
            end
        end
        
        function tags=get_curves_tag(obj)
            tags=cell(1,length(obj.Curves));
            for i=1:length(obj.Curves)
                tags{i}=obj.Curves(i).Tag;
            end
            tags=unique(tags);
        end
        
        function curves_obj=get_curves_per_type(layer_obj,type)
            if isempty(layer_obj.Curves)
                curves_obj=[];
            else
                curves_obj=layer_obj.Curves(strcmp({layer_obj.Curves(:).Type},type));
            end
        end
        
         function rm_curves_per_ID(obj,ID)
            if ~isempty(obj.Curves)
                idx=strcmp({obj.Curves(:).Unique_ID},ID);
                obj.Curves(idx)=[];
            end
         end
        
        function rm_curves_per_ID_and_type(obj,ID,type)
            if ~isempty(obj.Curves)
                idx=strcmp({obj.Curves(:).Unique_ID},ID)&strcmp({obj.Curves(:).Type},type);
                obj.Curves(idx)=[];
            end
        end
        
        function idx=get_curves_per_tag(obj,tag)
            if isempty(obj.Curves)
                idx=[];
            else
                idx=find(strcmp({obj.Curves(:).Tag},tag));
            end
        end
        
        function clear_curves(obj)
            obj.Curves=[];
        end
        
        function delete(obj)
            
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
    end
    
end