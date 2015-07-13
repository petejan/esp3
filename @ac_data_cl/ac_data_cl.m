
classdef ac_data_cl < handle
    properties
        SubData
        Fieldname
        Type
        Range
        Time
        Number
        MatfileData
    end
    
    
    methods
        function obj = ac_data_cl(varargin)
            p = inputParser;
            
            check_sub_ac_data_class=@(sub_ac_data_obj) isa(sub_ac_data_obj,'sub_ac_data_cl');
            check_data_class=@(obj) isa(obj,'matlab.io.MatFile');
            
            def_data.power=10.^(-100/10)*ones(1000,1000);
            save([pwd '/data.mat'],'-struct','def_data','-v7.3');
            daf_matfile_data=matfile([pwd '/data.mat'],'writable',true);
            
            addParameter(p,'MatfileData',daf_matfile_data,check_data_class);
            addParameter(p,'SubData',sub_ac_data_cl('power'),check_sub_ac_data_class);
            addParameter(p,'Range',(1:1000)/10,@isnumeric);
            addParameter(p,'Time',(1:1000)/10,@isnumeric);
            addParameter(p,'Number',1:1000,@isnumeric);
                     
            parse(p,varargin{:});
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
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
            
            if length(data_2.Fieldname)==length(data_1.Fieldname)
                ff_1=who(data_1.MatfileData);
                for uuu=1:length(ff_1)
                    curr_data.(ff_1{uuu})=[data_1.MatfileData.(ff_1{uuu}) data_2.MatfileData.(ff_1{uuu})];
                end
                save(data_1.MatfileData.Properties.Source,'-struct','curr_data','-v7.3');
                curr_matfile=matfile(data_1.MatfileData.Properties.Source,'writable',true);
                clear curr_data;
                
                data_out=ac_data_cl('SubData',concatenate_SubData(data_1.SubData,data_2.SubData),...
                    'Range',data_1.Range,...
                    'Time',[data_1.Time data_2.Time],...
                    'Number',[data_1.Number data_1.Number(end)+data_2.Number],...
                    'MatfileData',curr_matfile);
            else
                error('Cannot concatenate two dataset having different subdatasets')
            end
        end
        
        function add_sub_data(data,subdata)
            subdata_temp=data.SubData;
            
            for i=1:length(subdata)
                fieldname=subdata(i).Fieldname;
                [idx,found]=find_field_idx(data,fieldname);
                if found==0
                    subdata_temp=[subdata_temp subdata(i)];
                    data.Fieldname=[data.Fieldname {subdata.Fieldname}];
                    data.Type=[data.Type {subdata.Type}];
                else
                    subdata_temp(idx)=subdata(i);
                end
            end
            
            data.SubData=subdata_temp;
            
        end
        
        
    end
end

