function hfigs=clean_echo_figures(main_figure,varargin)
p = inputParser;
addRequired(p,'main_figure',@(x) isempty(x)||ishandle(x));
addParameter(p,'Tag','',@(x) ischar(x)||iscell(x)||isempty(x));

parse(p,main_figure,varargin{:});

if ~isempty(main_figure)
    hfigs=getappdata(main_figure,'ExternalFigures');
    if isempty(p.Results.Tag)
        for uuui=1:length(hfigs)
            if isvalid(hfigs(uuui))
                close(hfigs(uuui));
            end
        end
        delete(hfigs);  
    else
        
        if ischar(p.Results.Tag)
            Tag={p.Results.Tag};
        else
            Tag=p.Results.Tag;
        end
        for i=1:numel(Tag)
            if ~isempty(hfigs)
                hfigs(~isvalid(hfigs))=[];
                idx_tag=find(strcmpi({hfigs(:).Tag},Tag{i}));
                if ~isempty(idx_tag)
                    delete(hfigs(idx_tag));
                end
            end
        end
    end
    
else
   hfigs=[]; 
end