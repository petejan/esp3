
classdef ac_data_cl < handle
    properties
        SubData
        Fieldname
        Type
        Range
        Time
        Number
        MemapName
    end
    
    
    methods
        function obj = ac_data_cl(varargin)
            p = inputParser;
            
            check_sub_ac_data_class=@(sub_ac_data_obj) isa(sub_ac_data_obj,'sub_ac_data_cl')||isempty(sub_ac_data_obj);
               
            def_name=fullfile(tempdir,'init_0');
            i=0;
            while exist([def_name 'sv.bin'],'file')>0
                i=i+1;
                def_name=[fullfile(tempdir,'init') '_' num2str(i,'%.0f')];
            end
            
            addParameter(p,'SubData',[],check_sub_ac_data_class);
            addParameter(p,'Range',(1:100)/10,@isnumeric);
            addParameter(p,'Time',(1:100)/10,@isnumeric);
            addParameter(p,'Number',1:100,@isnumeric);
            addParameter(p,'MemapName',def_name,@ischar);
            
            parse(p,varargin{:});
            
            results=p.Results;
            props=fieldnames(results);
                        
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
            
            if isempty(p.Results.SubData)
                power=10.^(-100/10)*ones(100,100);
               obj.SubData=sub_ac_data_cl('sv',def_name,power);
            end
            
            fieldname=cell(1,length(obj.SubData));
            type=cell(1,length(obj.SubData));
            for i=1:length(obj.SubData)
                fieldname{i}=obj.SubData(i).Fieldname;
                type{i}=obj.SubData(i).Type;
            end
            obj.Fieldname=fieldname;
            obj.Type=type;
        end
        
        function data_out=concatenate_Data(data_1,data_2)
            
           if data_1.Time(1)>=data_2.Time(end)
                 data_temp=data_1;
                 data_1=data_2;
                 data_2=data_temp;
           end
            
            ff_1=data_1.Fieldname;
            %ff_2=data_1.Fieldname;
            
            new_sub_data=[];
            
            [dir_data,~,~]=fileparts(data_1.SubData(1).Memap.Filename);

            [~,curr_filename,~]=fileparts(tempname);
            new_name=fullfile(dir_data,curr_filename);
            
            
            for uuu=1:length(ff_1)
                [idx,found]=find_field_idx(data_2,ff_1{uuu});
                if found
                    new_sub_data=[new_sub_data; concatenate_SubData(data_1.SubData(uuu),data_2.SubData(idx),new_name)];
                else
                    warning('Cannot find field');
                end
            end

            data_out=ac_data_cl('SubData',new_sub_data,...
                'Range',data_1.Range,...
                'Time',[data_1.Time data_2.Time],...
                'Number',[data_1.Number data_1.Number(end)+data_2.Number],...
                'MemapName',new_name);

            
        end
        
        
        function add_sub_data(data,subdata)
            subdata_temp=data.SubData;
            
            for i=1:length(subdata)
                fieldname=subdata(i).Fieldname;
                [idx,found]=find_field_idx(data,fieldname);
                if found==0
                    subdata_temp=[subdata_temp subdata(i)];
                    data.Fieldname=[data.Fieldname subdata(i).Fieldname];
                    data.Type=[data.Type subdata(i).Type];
                else 
                    subdata_temp(idx).Memap.Writable=false;
                    delete(subdata_temp(idx).Memap.Filename);
                    subdata_temp(idx)=subdata(i);
                end
            end
            
            data.SubData=subdata_temp;
            
        end
        
        function remove_sub_data(data,fieldname)
            subdata_temp=data.SubData;
            [idx,found]=find_field_idx(data,fieldname);

                if found==0
                    return;
                else                   
                   subdata_temp(idx).Memap.Writable=false;
                    subdata_temp(idx)=[];
                    data.Type(idx)=[];
                    data.Fieldname(idx)=[];
                end

            data.SubData=subdata_temp;
            
        end
        
        
    end
end

