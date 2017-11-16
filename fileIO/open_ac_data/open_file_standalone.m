function [new_layers,multi_lay_mode]=open_file_standalone(Filename,ftype,varargin)

p = inputParser;

if ~iscell(Filename)
    Filename={Filename};
end

[def_path_m,~,~]=fileparts(Filename{1});

addRequired(p,'Filename',@(x) ischar(x)||iscell(x));
addRequired(p,'ftype',@(x) ischar(x));
addParameter(p,'PathToMemmap',def_path_m,@ischar);
addParameter(p,'load_bar_comp',[]);
addParameter(p,'dfile',0,@isnumeric);
addParameter(p,'CVSCheck',0);
addParameter(p,'CVSroot','');
addParameter(p,'SvCorr',1);
addParameter(p,'Calibration',[]);
addParameter(p,'Frequencies',[]);
addParameter(p,'PingRange',[1 inf]);
addParameter(p,'SampleRange',[1 inf]);
addParameter(p,'FieldNames',{});
addParameter(p,'EsOffset',[]);
addParameter(p,'GPSOnly',0);
addParameter(p,'LoadEKbot',0);
addParameter(p,'force_open',0);


new_layers=[];
multi_lay_mode=[];

parse(p,Filename,ftype,varargin{:});

    % Open the files. Different behavior per type of file
    switch ftype
        
        case 'fcv30'
            new_layers=[];
            for ifi = 1:length(Filename)
                lays_tmp=open_FCV30_file(Filename{ifi},...
                    'PathToMemmap',p.Results.PathToMemmap,'p.Results.load_bar_comp',p.Results.load_bar_comp);
                new_layers=[new_layers lays_tmp];
            end
            multi_lay_mode=0;
            
        case {'EK60','EK80'}            
            new_layers=open_EK_file_stdalone(Filename,...
                'PathToMemmap',p.Results.PathToMemmap,...
                'LoadEKbot',p.Results.LoadEKbot,...
                'load_bar_comp',p.Results.load_bar_comp,...
                'EsOffset',p.Results.EsOffset,...
                'PingRange',p.Results.PingRange,...
                'SampleRange',p.Results.SampleRange,...
                'Frequencies',p.Results.Frequencies,...
                'GPSOnly',p.Results.GPSOnly,...
                'FieldNames',p.Results.FieldNames,...
                'PathToMemmap',p.Results.PathToMemmap,...
                'load_bar_comp',p.Results.load_bar_comp,...
                'force_open',p.Results.force_open);           
            multi_lay_mode=0;
        case 'asl'
            
            new_layers=open_asl_files(Filename,...
                'PathToMemmap',p.Results.PathToMemmap,'load_bar_comp',p.Results.load_bar_comp);            
            multi_lay_mode=0;
            
        case 'dfile'
             switch p.Results.dfile
                case 1
                    new_layers=read_crest(Filename,...
                        'PathToMemmap',p.Results.PathToMemmap,'CVSCheck',p.Results.CVSCheck,'CVSroot',p.Results.CVSroot,'SvCorr',p.Results.SvCorr);
                case 0
                    new_layers=open_dfile(Filename,'CVSCheck',p.Results.CVSCheck,'CVSroot',p.Results.CVSroot,...
                        'PathToMemmap',p.Results.PathToMemmap,'load_bar_comp',p.Results.load_bar_comp,'EsOffset',p.Results.EsOffset);
            end
            multi_lay_mode=0;
            
        case 'invalid'
            for ifi=1:length(Filename)
                fprintf('Could not open %s\n',Filename{ifi});
            end
        otherwise
            for ifi=1:length(Filename)
                fprintf('Unrecognized File type for Filename %s\n',Filename{ifi});
            end         
    end