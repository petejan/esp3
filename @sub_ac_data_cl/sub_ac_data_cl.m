
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
                     
            switch obj.Fieldname
                case  'sv'
                    obj.CaxisDisplay=[-80 -35];
                    obj.Type='Sv';
                case 'svdenoised'
                    obj.CaxisDisplay=[-80 -35];
                    obj.Type='Denoised Sv';
                case 'sp'
                    obj.CaxisDisplay=[-60 -30];
                    obj.Type='Sp';
                case    'spdenoised'
                    obj.CaxisDisplay=[-60 -30];
                    obj.Type='Denoised Sp';
                case    'spunmatched'
                    obj.CaxisDisplay=[-60 -30];
                    obj.Type='Sp before match filtering';
                case 'power'
                    obj.CaxisDisplay=[-200 0];
                    obj.Type='Power';
                case 'powerdenoised'
                    obj.CaxisDisplay=[-200 0];
                    obj.Type='Denoised Power';
                case'y'
                    obj.CaxisDisplay=[-200 0];
                    obj.Type='y';
                case 'singletarget'
                    obj.CaxisDisplay=[];
                    obj.Type='Single Targets compensated TS';
                case 'snr'
                    obj.CaxisDisplay=[0 30];
                    obj.Type='SNR';
                case 'acrossphi'
                    obj.CaxisDisplay=[-180 180];
                    obj.Type='Phase Across';
                case 'alongphi'
                    obj.CaxisDisplay=[-180 180];
                    obj.Type='Phase Along';
                case 'alongangle'
                    obj.CaxisDisplay=[];
                    obj.Type='Angle Along';
                case 'acrossangle'
                    obj.CaxisDisplay=[];
                    obj.Type='Angle Across';
                otherwise
                    obj.CaxisDisplay=[];
                    obj.Type=obj.Fieldname;
            end
            
            if isempty(obj.CaxisDisplay);
                obj.CaxisDisplay=[nanmin(real(data(:))) nanmax(real(data(:)))];
            end
            
            if obj.CaxisDisplay(1)>=obj.CaxisDisplay(2)
                obj.CaxisDisplay=[obj.CaxisDisplay(1) obj.CaxisDisplay(1)+abs(obj.CaxisDisplay(1))/10];
            end
        end
        
        function sub_out=concatenate_SubData(sub_1,sub_2,new_name)
            
            if ~strcmp(sub_1.Fieldname,sub_2.Fieldname)

                warning('Concatenating two different subdataset'); 
            end
            
            data_1=sub_1.Memap.Data.(sub_1.Fieldname);
            data_2=sub_2.Memap.Data.(sub_2.Fieldname);
            
            new_data=[data_1 data_2];
            
            sub_1.Memap.Writable=false;
            sub_2.Memap.Writable=false;
            
            %clear sub_1.Memap sub_2.Memap data1 data2
            
            delete(sub_1.Memap.Filename);
            delete(sub_2.Memap.Filename);
            
            sub_out=sub_ac_data_cl(sub_1.Fieldname,new_name,new_data);

        end
        
       
    end
end
