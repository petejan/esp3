%% get_algos.m
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
% * |input_variable_1|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |output_variable_1|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-07-06: start commenting and header (Alex Schimel).
% * YYYY-MM-DD: first version (Author). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function algo_cell = get_algos(algo_node)

% number of algorithms
nb_algos = length(algo_node.Children);

% initialize output
algo_cell = cell(1,nb_algos);

% get each algo details
for i = 1:nb_algos

    % ignore comments
    if strcmp(algo_node.Children(i).Name,'#comment')
        continue;
    end
    
    % record algo name
    algo_cell{i}.Name = algo_node.Children(i).Name;
    
    % record each attribute
    for j = 1:length(algo_node.Children(i).Attributes)
        algo_cell{i}.Varargin.(algo_node.Children(i).Attributes(j).Name) = algo_node.Children(i).Attributes(j).Value;
    end
    
    % special record for frequencies if this field exists
    if isfield(algo_cell{i}.Varargin,'Frequencies')
        if ischar(algo_cell{i}.Varargin.Frequencies)
            algo_cell{i}.Varargin.Frequencies = str2double(strsplit(algo_cell{i}.Varargin.Frequencies,';'));
            if isnan(algo_cell{i}.Varargin.Frequencies)
                algo_cell{i}.Varargin.Frequencies = [];
            end
        end
    else
        algo_cell{i}.Varargin.Frequencies = [];
    end
    
    if ~isfield(algo_cell{i}.Varargin,'savename')
        algo_cell{i}.Varargin.savename = '--';
    end
    
end

% remove empty algorithms (comments)
algo_cell(cellfun(@isempty,algo_cell)) = [];

end