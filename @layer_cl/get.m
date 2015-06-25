function varargout=get(obj,varargin)

varargout = [];
for i=1:length(varargin)
    
    if  isprop(obj,varargin{i})
        varargout{end+1}=eval(['obj.' varargin{i}]);
    else
        w = sprintf('layer_cl : Property %s does not exist', varargin{i});
        warndlg(w);
    end
    
end

end