function open_dropped_file(evt,main_figure,varargin)
p = inputParser;

addRequired(p,'evt',@isstruct);
addRequired(p,'main_figure',@(h) isempty(h)|isa(h,'matlab.ui.Figure'));
addParameter(p,'fType','',@ischar);

parse(p,evt,main_figure,varargin{:});

if ~iscell(evt.Data)
    evt.Data={evt.Data};
end
switch p.Results.fType
    case ''
        [path_f,file_f,ext_f]=cellfun(@fileparts,evt.Data,'uniformoutput',0);
        [ext_fa,~,ic]=unique(ext_f);
        ftype=cell(1,length(ext_fa));
        files=cell(1,length(ext_fa));
        for i=1:length(ext_fa)
            switch ext_fa{i}
                case {'.raw','.lst'}
                    ftype{i}='acoustic';
                case {'.evl' '.cnv' '.dat'}
                    ftype{i}='line';
                case {'.csv' '.txt' '.log',}
                    ftype{i}='data';
                otherwise
                    ftype{i}='unknown';
            end
            idx_f=ic==i;
            files{i}=fullfile(path_f(idx_f),cellfun(@(x,y) [x y],file_f(idx_f),ext_f(idx_f),'uniformoutput',0));
        end
    otherwise
        ftype{1}={p.Results.fType};
        files{1}=evt.Data;
end
layer=getappdata(main_figure,'Layer');

for ifi=1:length(ftype)
    try
        switch ftype{ifi}
            case 'acoustic'
                open_file([],[],files{ifi},main_figure);
            case 'line'
                if isempty(layer)
                    continue
                end
                for il=1:length(files{ifi})
                    line=import_line(files{ifi}{il});
                    if isempty(line)
                        continue
                    end
                    layer.add_lines(line);
                end
            case 'data'
                if isempty(layer)
                    continue;
                end
                idx_att= find(cellfun(@(x)~isempty(regexp(x,'\<(3DM).*(.log)\>', 'once')),files{ifi})|...
                    cellfun(@(x)~isempty(regexp(x,'.*(att.csv)\>', 'once')),files{ifi})|...
                    cellfun(@(x)~isempty(regexp(x,'.*(att_data.csv)\>', 'once')),files{ifi}));
                idx_gps= find(cellfun(@(x)~isempty(regexp(x,'.*(gps.csv)\>', 'once')),files{ifi})|...
                    cellfun(@(x)~isempty(regexp(x,'.*(gps_data.csv)\>', 'once')),files{ifi}));
                idx_line= find(cellfun(@(x)~isempty(regexp(x,'\<(SUPERVISOR).*(.log)\>', 'once')),files{ifi})|...
                    cellfun(@(x)~isempty(regexp(x,'.*(.dat)\>', 'once')),files{ifi}));
                
                if ~isempty(idx_att)
                    attitude_full=attitude_nav_cl.load_att_from_file(files{ifi}(idx_att));
                    layer.add_attitude(attitude_full);
                end
                
                
                if ~isempty(idx_gps)
                    gps_data=gps_data_cl.load_gps_from_file(files{ifi}(idx_gps));
                    layer.replace_gps_data_layer(gps_data);
                end
                
                if ~isempty(idx_line)
                    for iline=1:length(idx_line)
                        line=import_line(files{ifi}{idx_line(iline)});
                        layer.add_lines(line);
                    end
                    
                end
                
                
        end
    catch
        warning('Could not import file(s)');
    end
end

loadEcho(main_figure);

end