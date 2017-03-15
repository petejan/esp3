function filter_bottom(trans_obj,varargin)

p = inputParser;

addRequired(p,'trans_obj',@(x) isa(x,'transceiver_cl'));
addParameter(p,'FilterWidth',10,@isnumeric);

parse(p,trans_obj,varargin{:});

results=p.Results;

bot_data=trans_obj.get_bottom_idx();

%bot_data_filt=round(filter2_perso(ones(1,results.FilterWidth),bot_data));
bot_data_filt=round(smooth(bot_data,results.FilterWidth));
new_bot=bottom_cl('Origin',trans_obj.Bottom.Origin,....
                'Sample_idx',bot_data_filt,'Tag',trans_obj.Bottom.Tag);

trans_obj.setBottom(new_bot);


end