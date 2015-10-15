function string = getStringEorF(mbs, input, varargin) % returns a
% formatted string as fprintf input with %.5e for exponential
% number and %f for 0.
if nargin ==4;
    if strcmpi(varargin{2},'before')
        pre =  varargin{1};
        post = '';
    else
        post = varargin{1};
        pre = '';
    end
else
    pre = '';
    post = '';
end
if~isempty(input)
    
    a = find(input~=0);
    b = find(input==0);
    for i = 1:length(a)
        string{a(i)}= [pre ',%.5e' post];
    end
    
    for i = 1:length(b)
        string{b(i)}= [pre ',%.f' post];
    end
    
    string = cell2mat(string);
else
    string='';
end
end