
classdef layer_cl < handle
    properties
        ID_num=0;
        Filename='';
        Filetype='';
        PathToFile='';
        Transceivers
        Lines
        Frequencies
        GPSData
        AttitudeNav
        EnvData
        Curves
    end
    
    
    methods
        function obj = layer_cl(varargin)
            p = inputParser;
            
            
            check_att_class=@(obj) isa(obj,'attitude_nav_cl');
            check_gps_class=@(gps_data_obj) isa(gps_data_obj,'gps_data_cl');
            check_curve_cl=@(curve_obj) isempty(curve_obj)|isa(curve_obj,'curve_cl');
            check_env_class=@(env_data_obj) isa(env_data_obj,'env_data_cl');
            check_transceiver_class=@(transceiver_obj) isa(transceiver_obj,'transceiver_cl')|isempty(transceiver_obj);
            check_line_class=@(obj) isa(obj,'line_cl')|isempty(obj);
            
            addParameter(p,'ID_num',0,@isnumeric);
            addParameter(p,'Filename','Dummy Data',@(fname)(ischar(fname)||iscell(fname)));
            addParameter(p,'Filetype','EK60',@(ftype)(ischar(ftype)));
            addParameter(p,'PathToFile',pwd,@(fname)(ischar(fname)||iscell(fname)));
            addParameter(p,'Transceivers',[],check_transceiver_class);
            addParameter(p,'Lines',[],check_line_class);
            addParameter(p,'Frequencies',38000,@isnumeric);
            addParameter(p,'GPSData',gps_data_cl(),check_gps_class);
            addParameter(p,'Curves',[],check_curve_cl);
            addParameter(p,'AttitudeNav',attitude_nav_cl(),check_att_class);
            addParameter(p,'EnvData',env_data_cl(),check_env_class);
            
            parse(p,varargin{:});
            
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                
                obj.(props{i})=results.(props{i});
                
            end
            
            if isempty(p.Results.Transceivers)
                obj.Transceivers=transceiver_cl();
            end
        end
        
        function delete(layer)
            
            for kk=1:length(layer.Transceivers)
                for uu=1:length(layer.Transceivers(kk).Data.SubData)
                    if isa(layer.Transceivers(kk).Data.SubData(uu).Memap,'memmapfile')
                        if exist(layer.Transceivers(kk).Data.SubData(uu).Memap.Filename,'file')>0
                            layer.Transceivers(kk).Data.SubData(uu).Memap.Writable=false;
                            %clear layer.Transceivers(kk).Data.SubData(uu).Memap.Data
                            delete(layer.Transceivers(kk).Data.SubData(uu).Memap.Filename);
                        end
                    end
                end
                
            end
        end
        
        function layer_out=concatenate_Layer(layer_1,layer_2)
            if iscell(layer_1.Filename)||iscell(layer_2.Filename)
                newname=[layer_1.Filename layer_2.Filename];
            else
                newname={layer_1.Filename layer_2.Filename};
            end
            layer_out=layer_cl('ID_num',layer_1.ID_num,...
                'Filename',newname...
                ,'Filetype',layer_1.Filetype,...
                'PathToFile',layer_1.PathToFile,...
                'Transceivers',concatenate_Transceivers(layer_1.Transceivers,layer_2.Transceivers),...
                'AttitudeNav',concatenate_AttitudeNavPing(layer_1.AttitudeNav,layer_2.AttitudeNav),...
                'GPSData',concatenate_GPSData(layer_1.GPSData,layer_2.GPSData),...
                'Frequencies',layer_1.Frequencies);
            
        end
        
        function rm_region_across_id(layer,ID)                                
            for i=1:length(layer.Transceivers)
                layer.Transceivers(i).rm_region_id(ID);
            end           
        end
        
        function copy_region_across(layer,idx_freq,active_reg)
            
            Transceiver=layer.Transceivers(idx_freq);
            range_ori=Transceiver.Data.Range;
            time_ori=Transceiver.Data.Time;
            
            dr_ori=nanmean(diff(range_ori));
            dt_ori=nanmean(diff(time_ori));
            
            sv_reg_ori=active_reg.Sv_reg;
            mask_reg_ori=~isnan(sv_reg_ori);
            [nb_samples_ori,nb_pings_ori]=size(sv_reg_ori);
            [S_ori,P_ori]=meshgrid(1:nb_samples_ori,1:nb_pings_ori);
            
            
            for i=1:length(layer.Transceivers)
                if i==idx_freq
                    continue;
                end
                
                Transceiver_2=layer.Transceivers(i);
                new_range=Transceiver_2.Data.Range;
                new_time=Transceiver_2.Data.Time;
                
                Sv=layer.Transceivers(i).Data.get_datamat('svdenoised');
                
                if isempty(Sv)
                    Sv=layer.Transceivers(i).Data.get_datamat('sv');
                end
                
                dr=nanmean(diff(new_range));
                dt=nanmean(diff(new_time));
                
                [~,idx_ping_start]=nanmin(abs(new_time-time_ori(active_reg.Idx_pings(1))));
                [~,sample_start]=nanmin(abs(new_range-range_ori(active_reg.Idx_r(1))));
                [~,idx_ping_end]=nanmin(abs(new_time-time_ori(active_reg.Idx_pings(end))));
                [~,sample_end]=nanmin(abs(new_range-range_ori(active_reg.Idx_r(end))));
                
                idx_pings=idx_ping_start:idx_ping_end;
                idx_r=sample_start:sample_end;
                
                switch active_reg.Cell_w_unit
                    case 'pings'
                        cell_w=nanmax(round(active_reg.Cell_w*dt_ori/dt),1);
                    case 'meters'
                        cell_w=active_reg.Cell_w;
                end
                
                switch active_reg.Cell_h_unit
                    case 'samples'
                        cell_h=nanmax(round(active_reg.Cell_h*dr_ori/dr),1);
                    case 'meters'
                        cell_h=active_reg.Cell_h;
                        
                end
                
                switch active_reg.Shape
                    case 'Polygon'
                        [nb_samples,nb_pings]=size(Sv(idx_r,idx_pings));
                        [S,P]=meshgrid(1:nb_samples,1:nb_pings);
                        F=scatteredInterpolant(S_ori(:),P_ori(:),double(mask_reg_ori(:)),'nearest','nearest');
                        new_mask=F(S,P);
                        sv_reg=Sv(idx_r,idx_pings);
                        sv_reg(new_mask<1)=nan;
                        
                    otherwise
                        sv_reg=Sv(idx_r,idx_pings);
                end
                
                reg_temp=region_cl(...
                    'ID',new_id(layer.Transceivers(i),active_reg.Name),...
                    'Unique_ID',active_reg.Unique_ID,...
                    'Name',active_reg.Name,...
                    'Type',active_reg.Type,...
                    'Idx_pings',idx_pings,...
                    'Idx_r',idx_r,...
                    'Shape',active_reg.Shape,...
                    'Sv_reg',sv_reg,...
                    'Reference','Surface',...
                    'Cell_w',cell_w,...
                    'Cell_w_unit',active_reg.Cell_w_unit,...
                    'Cell_h',cell_h,...
                    'Cell_h_unit',active_reg.Cell_h_unit,...
                    'Output',[]);
                
                reg_temp.integrate_region(layer.Transceivers(i));
                
                layer.Transceivers(i).add_region(reg_temp);
            end
            
        end
        
        function list=list_lines(obj)
            if isempty(obj.Lines)
                list={};
            else
                list=cell(1,length(obj.Lines));
                for i=1:length(obj.Lines)
                    [~,name,ext]=fileparts(obj.Lines(i).File_origin);
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
                obj.Lines=[obj.Lines lines(i)];
            end
        end
        
        function add_curves(obj,curves)
            for i=1:length(curves)
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
        
        function idx=get_curves_per_tag(obj,tag)
            idx=[];
            for i=1:length(obj.Curves)
                if strcmp(obj.Curves(i).Tag,tag);
                    idx=[idx i];
                end
            end
        end
        
        function clear_curves(obj)
            obj.Curves=[];
        end
        
    end
    
end



