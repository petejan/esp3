function bot_depth=get_bottom_depth(trans_obj,varargin)

bot_depth=trans_obj.get_bottom_range(varargin{:})-trans_obj.get_transducer_depth(varargin{:});


    