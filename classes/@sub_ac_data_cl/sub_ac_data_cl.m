
classdef sub_ac_data_cl < handle
    properties
        Memap
        Type
        Fieldname
        CaxisDisplay
    end
    events
        UpdateGraph
    end
    methods
        function obj = sub_ac_data_cl(field,memapname,data)
            
            obj.Fieldname=lower(deblank(field));
            
            curr_name=[memapname field '.bin'];
            fileID = fopen(curr_name,'w+');
            
            while fileID==-1
                return;
            end
            
            format={'single',size(data),field};
            fwrite(fileID,single(data),'single');
            fclose(fileID);
            
            obj.Memap = memmapfile(curr_name,...
                'Format',format,'repeat',1,'writable',false);
            [obj.CaxisDisplay,obj.Type]=init_cax(obj.Fieldname);
           
            
            if isempty(obj.CaxisDisplay);
                obj.CaxisDisplay=[nanmin(real(data(:))) nanmax(real(data(:)))];
            end
            
            if obj.CaxisDisplay(1)>=obj.CaxisDisplay(2)
                obj.CaxisDisplay=[obj.CaxisDisplay(1) obj.CaxisDisplay(1)+abs(obj.CaxisDisplay(1))/10];
            end
        end
        
        function delete(obj)
            if isa(obj.Memap,'memmapfile')
                if exist(obj.Memap.Filename,'file')>0
                    obj.Memap.Writable=false;
                    delete(obj.Memap.Filename);
                end
            end
        end
        
        function sub_out=concatenate_SubData(sub_1,sub_2,new_name)
            
            if ~strcmp(sub_1.Fieldname,sub_2.Fieldname)
                warning('Concatenating two different subdataset'); 
            end
            
            data_1=sub_1.Memap.Data.(sub_1.Fieldname);
            data_2=sub_2.Memap.Data.(sub_2.Fieldname);
            
            new_data=[data_1 data_2];   
            sub_out=sub_ac_data_cl(sub_1.Fieldname,new_name,new_data);

        end
        
       
    end
    
    methods (Static)
      [sub_ac_data_temp,curr_name]=sub_ac_data_from_struct(curr_data,dir_data,fieldnames);
   end
   ...
end
