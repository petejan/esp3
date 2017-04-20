function evl_str=bottom_to_evl_str(trans_obj)

bot_obj=trans_obj.Bottom;
bot_r=trans_obj.get_bottom_range();
time=trans_obj.Time;

evl_str=sprintf('EVBD 3 5.3.45.23076\n');
evl_str=[evl_str sprintf('%d\n',nansum(~isnan(bot_r)))];
for ui=1:length(time);
    str_time=[datestr(time(ui),'YYYYmmDD HHMMSSFFF') '0'];
    depth=bot_r(ui);
    if isnan(depth)
        continue;
    end
    switch bot_obj.Tag(ui)
        case 0
            tag=2;
        otherwise
            tag=3;
    end
    evl_str=[evl_str sprintf('%s %.6f %d\n',str_time,depth,tag)];
end

end