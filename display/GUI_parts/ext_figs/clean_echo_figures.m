%% clean_echo_figures.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |main_figure|: TODO: write description and info on variable
% * |Tag|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |hfigs|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-04-02: header (Alex Schimel).
% * 2017-03-29: first version (Yoann Ladroit).
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
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
    setappdata(main_figure,'ExternalFigures',hfigs);
else
   hfigs=[]; 
end