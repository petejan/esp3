
classdef sub_ac_data_cl < handle
    properties
        Memap
        Type
        Fieldname
    end
    methods
        function obj = sub_ac_data_cl(field,memapname,data,varargin)
            
             p = inputParser;
            
            checkname=@(name) iscell(name)||ischar(name);
            checkdata=@(data) iscell(data)||isnumeric(data);
            
            addRequired(p,'field',@ischar);
            addRequired(p,'memapname',checkname);
            addRequired(p,'data',checkdata);

            parse(p,field,memapname,data,varargin{:});

            obj.Fieldname=lower(deblank(field));
            
            if ischar(memapname)
                memapname={memapname};
            end
            
            if ~iscell(data)
                data={data};
            end
            
  
           [~,obj.Type]=init_cax(obj.Fieldname);
            obj.Memap={};

            for icell=1:length(data)
                if ~isempty(data{icell})
                    curr_name=[memapname{icell} field '.bin'];
                   
                    fileID = fopen(curr_name,'w+');
                    while fileID==-1
                        continue;
                    end
                    format={'single',size(data{icell}),field};
                    fwrite(fileID,single(data{icell}),'single');
                    fclose(fileID);
                    
                    obj.Memap{icell} = memmapfile(curr_name,...
                        'Format',format,'repeat',1,'writable',true);

                end
            end
            

            
        end

    end
    
    methods (Static)
      [sub_ac_data_temp,curr_name]=sub_ac_data_from_struct(curr_data,dir_data,fieldnames);
   end
   ...
end
