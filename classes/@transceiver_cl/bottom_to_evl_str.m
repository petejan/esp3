function evl_str=bottom_obj_to_evl_str(trans_obj)

bot_obj=trans_obj.Bottom;
time=trans_obj.Data.Time;

evl_str=sprintf('EVBD 3 5.3.45.23076\n');
evl_str=[evl_str sprintf('%d\n',nansum(~isnan(bot_obj.Range)))];
for ui=1:length(time);
    str_time=[datestr(time(ui),'YYYYmmDD HHMMSSFFF') '0'];
    depth=bot_obj.Range(ui);
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