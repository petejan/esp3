
classdef sub_ac_data_cl < handle
    properties
        %DataMat
        Type
        Fieldname
        CaxisDisplay
    end
    events
        UpdateGraph
    end
    methods
        function obj = sub_ac_data_cl(field,varargin)
            
            obj.Fieldname=lower(deblank(field));
            %obj.DataMat=data_mat;
            
            
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
            
            if isempty(obj.CaxisDisplay)&&~isempty(varargin);
                obj.CaxisDisplay=varargin{1};
            end
            
            if obj.CaxisDisplay(1)>=obj.CaxisDisplay(2)
                obj.CaxisDisplay=[obj.CaxisDisplay(1) obj.CaxisDisplay(1)+abs(obj.CaxisDisplay(1))/10];
            end
        end
        
        function sub_out=concatenate_SubData(sub_1,sub_2)
            for i=1:length(sub_1)
                if strcmp(sub_1(i).Fieldname,sub_2(i).Fieldname)==1;
                    sub_out(i)=sub_ac_data_cl(sub_1(i).Fieldname,sub_1(i).CaxisDisplay);
                end
            end
        end
        
        
    end
end
