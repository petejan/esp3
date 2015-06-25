
classdef ac_data_cl < handle
    properties
        SubData
        Type
        Range
        Time
        Number
    end
    
    
    methods
        function obj = ac_data_cl(varargin)
            p = inputParser;
            
            check_sub_ac_data_class=@(sub_ac_data_obj) isa(sub_ac_data_obj,'sub_ac_data_cl');
            
            addParameter(p,'SubData',sub_ac_data_cl('Power',10.^(-100/10)*ones(1000,1000)),check_sub_ac_data_class);
            addParameter(p,'Type',{'Power'},@iscell);
            addParameter(p,'Range',(1:1000)/10,@isnumeric);
            addParameter(p,'Time',(1:1000)/10,@isnumeric);
            addParameter(p,'Number',1:1000,@isnumeric);

            
            parse(p,varargin{:});
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
            type=cell(1,length(obj.SubData));
            for i=1:length(obj.SubData)
                type{i}=obj.SubData(i).Type;
            end
            obj.Type=type;
        end
        
        function data_out=concatenate_Data(data_1,data_2)
            
            if length(data_2.Type)==length(data_1.Type)
            data_out=ac_data_cl('SubData',concatenate_SubData(data_1.SubData,data_2.SubData),...
                'Range',data_1.Range,...
                'Time',[data_1.Time data_2.Time],...
                'Number',[data_1.Number data_1.Number(end)+data_2.Number],...
                'Type',data_1.Type);
            else
                error('Cannot concatenate two dataset having different subdatasets')
            end
        end
        
        function add_sub_data(data,subdata)
            subdata_temp=data.SubData;
            for i=1:length(subdata)
                type=subdata(i).Type;
                [idx,found]=find_type_idx(data,type);
                    
                if found==0
                    subdata_temp=[subdata_temp subdata(i)];
                    data.Type=[data.Type {subdata.Type}];
                else
                    subdata_temp(idx)=subdata(i);    
                end
            end
            
            data.SubData=subdata_temp;
            
        end
        
        
    end
end

