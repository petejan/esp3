
classdef sub_ac_data_cl < handle
    properties
        Memap
        Type
        Fieldname
    end
    methods
        function obj = sub_ac_data_cl(varargin)
            
            p = inputParser;
            
            checkname=@(name) iscell(name)||ischar(name);
            checkdata=@(data) iscell(data)||isnumeric(data)||isa(data,'memmapfile');
            
            addParameter(p,'field','',@ischar);
            addParameter(p,'type','',@ischar);
            addParameter(p,'memapname','',checkname);
            addParameter(p,'data',[],checkdata);
            addParameter(p,'datasize',[1 1],@isnumeric);
            addParameter(p,'default_value',0,@isnumeric);
            
            parse(p,varargin{:});
            
            field=p.Results.field;
            memapname=p.Results.memapname;
            data=p.Results.data;
            
            obj.Fieldname=lower(deblank(field));
            
            if ischar(memapname)
                memapname={memapname};
            end
            
            if ~iscell(data)
                data={data};
            end
            
            if ~strcmpi(p.Results.type,'')
                obj.Type=p.Results.type;
            else
                [~,obj.Type]=init_cax(field);
            end
            
            obj.Memap={};
            
            for icell=1:length(data)
                switch class(data{icell})
                    case 'memmapfile'
                        obj.Memap{icell}=data{icell};
                    case 'char'
                        format={'single',p.Results.datasize,obj.Fieldname};
                        obj.Memap{icell} = memmapfile(data{icell},...
                                'Format',format,'repeat',1,'writable',true);
                    otherwise                       
                        if ~isempty(data{icell})
                            curr_name=[memapname{icell} obj.Fieldname '.bin'];
                            
                            fileID = fopen(curr_name,'w+');
                            while fileID==-1
                                continue;
                            end
                            
                            if numel(data{icell})==2
                                nb_samples=data{icell}(1);
                                nb_pings=data{icell}(2);
                                
                            else
                                [nb_samples,nb_pings]=size(data{icell});
                            end
                            format={'single',[nb_samples,nb_pings],obj.Fieldname};
                                                      
                            if numel(data{icell})==2
                                b_size=1000;
                                u=0;
                                while u<ceil(nb_pings*nb_samples/b_size)
                                    fwrite(fileID,p.Results.default_value*ones(1,nanmin(b_size,nb_samples*nb_pings-(b_size*u))),'single');
                                    u=u+1;
                                end
                                
                            else
                                fwrite(fileID,double(data{icell}),'single');
                            end
                            %fwrite(fileID,double(data{icell}),'single');
                            fclose(fileID);
                            
                            
                            obj.Memap{icell} = memmapfile(curr_name,'Format',format,'repeat',1,'writable',true);
                        else
                            obj.Memap{icell}=[];
                        end
                    
                end
            end
            
            
            
        end
        
        function obj_out=get_sub_data_file_id(obj,file_id)
            obj_out=sub_ac_data_cl('field',obj.Fieldname,'data',obj.Memap(file_id));
        end
        
        
        function delete(obj)
            
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
            %           for icell=1:length(obj.Memap)
            
            %             if ~isdeployed
            %                 disp(['Deleting file' ,obj.Memap{icell}.Filename]);
            %             end
            %
            %                file=obj.Memap{icell}.Filename;
            %                obj.Memap{icell}=[];
            %                delete(file);
            %           end
        end
        
    end
    
    methods (Static)
        [sub_ac_data_temp,curr_name]=sub_ac_data_from_struct(curr_data,dir_data,fieldnames);
        sub_ac_data_temp=sub_ac_data_from_files(dfiles,dsize,fieldnames);
    end

end
