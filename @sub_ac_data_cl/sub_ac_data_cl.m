
classdef sub_ac_data_cl < handle
    properties
        DataMat
        Type
        CaxisDisplay
        
    end
    events
        UpdateGraph
    end
    methods
        function obj = sub_ac_data_cl(type,data_mat)
            
            obj.Type=type;
            obj.DataMat=data_mat;
                        
            switch type
                case  {'Sv','Sv Denoised'}
                    obj.CaxisDisplay=[-80 -35];
                case {'Sp','Sp Denoised','Sp UnMatched'}
                    obj.CaxisDisplay=[-60 -30];
                case {'Power','Power Denoised'}
                    obj.CaxisDisplay=[nanmin(10*log10((data_mat(data_mat>0)))) nanmax(10*log10((data_mat(data_mat>0))))];
                case 'y'
                    obj.CaxisDisplay=[nanmin(10*log10(abs(data_mat(:)))) nanmax(10*log10(abs(data_mat(:))))];
                otherwise
                    obj.CaxisDisplay=[nanmin(real(data_mat(:))) real(nanmax(data_mat(:)))];
            end
            if obj.CaxisDisplay(1)>=obj.CaxisDisplay(2)
                obj.CaxisDisplay=[obj.CaxisDisplay(1) obj.CaxisDisplay(1)+abs(obj.CaxisDisplay(1))/10];    
            end
        end
        
        function sub_out=concatenate_SubData(sub_1,sub_2)
           for i=1:length(sub_1)
               sub_out(i)=sub_ac_data_cl(sub_1(i).Type,[sub_1(i).DataMat sub_2(i).DataMat]);
           end
        end
        
        %         function set.CaxisDisplay(obj,val)
        %             if length(val)==2
        %                 if val(1)>val(2)
        %                    val=fliplr(val);
        %                 end
        %                 obj.CaxisDisplay = val;
        %                 notify(obj,'UpdateGraph');
        %             end
        %         end
        
    end
end
