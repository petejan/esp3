classdef curr_state_disp_cl <handle
    
    properties (SetObservable = true)
        Freq
        Fieldname
        Type
        Xaxes
        Cax
        DispBottom
        DispTracks
        DispBadTrans
        DispReg
        DispLines
        Grid_x
        Grid_y
    end
    
    methods
        function obj =curr_state_disp_cl(varargin)
            
            p = inputParser;
            addParameter(p,'Freq',38000,@isnumeric);
            addParameter(p,'Fieldname','power',@ischar);
            addParameter(p,'Cax',[-100 -90],@ischar);
            addParameter(p,'DispBottom','on',@ischar);
            addParameter(p,'DispTracks','on',@ischar);
            addParameter(p,'DispBadTrans',true,@islogical);
            addParameter(p,'DispReg',true,@islogical);
            addParameter(p,'DispLines',true,@islogical);
            addParameter(p,'Xaxes','Number',@ischar);
            addParameter(p,'Grid_x',100,@isnumeric);
            addParameter(p,'Grid_y',100,@isnumeric);
            parse(p,varargin{:});
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
            
            obj.setTypeCax();
            
        end
    end
    
    methods
        function setTypeCax(obj)
            switch obj.Fieldname
                case  'sv'
                    obj.Cax=[-80 -35];
                    obj.Type='Sv';
                case 'svdenoised'
                    obj.Cax=[-80 -35];
                    obj.Type='Denoised Sv';
                case 'sp'
                    obj.Cax=[-60 -30];
                    obj.Type='Sp';
                case    'spdenoised'
                    obj.Cax=[-60 -30];
                    obj.Type='Denoised Sp';
                case    'spunmatched'
                    obj.Cax=[-60 -30];
                    obj.Type='Sp before match filtering';
                case 'power'
                    obj.Cax=[-200 0];
                    obj.Type='Power';
                case 'powerunmatched'
                    obj.Cax=[-200 0];
                    obj.Type='Power Before match Filtering';
                case 'powerdenoised'
                    obj.Cax=[-200 0];
                    obj.Type='Denoised Power';
                case'y_real'
                    obj.Cax=[-200 0];
                    obj.Type='Y_real';
                case'y_imag'
                    obj.Cax=[-200 0];
                    obj.Type='Y_imag';
                case 'singletarget'
                    obj.Cax=[];
                    obj.Type='Single Targets compensated TS';
                case 'snr'
                    obj.Cax=[0 30];
                    obj.Type='SNR';
                case 'acrossphi'
                    obj.Cax=[-180 180];
                    obj.Type='Phase Across';
                case 'alongphi'
                    obj.Cax=[-180 180];
                    obj.Type='Phase Along';
                case 'alongangle'
                    obj.Cax=[];
                    obj.Type='Angle Along';
                case 'acrossangle'
                    obj.Cax=[];
                    obj.Type='Angle Across';
                otherwise
                    obj.Cax=[];
                    obj.Type=obj.Fieldname;
            end
        end
        
        function setField(obj,field)
            obj.Fieldname=field;
            obj.setTypeCax();
        end
        
    end
    
end

