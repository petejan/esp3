function trans_out=concatenate_Transceivers(trans_1,trans_2)
if isempty(trans_1)
    trans_out=trans_2;
    return;
elseif isempty(trans_2)
    trans_out=trans_1;
    return;
end

if length(trans_1)==length(trans_2)
    trans_out(length(trans_1))=transceiver_cl();
    for i=1:length(trans_1)
        if trans_1(i).Time(1)>=trans_2(i).Time(end)
            trans_first=trans_2(i);
            trans_second=trans_1(i);
        else
            trans_first=trans_1(i);
            trans_second=trans_2(i);
        end
        
        trans_out(i)=transceiver_cl('Data',concatenate_Data(trans_first.Data,trans_second.Data),...
            'Range',trans_first.Range,...
            'Time',[trans_first.Time trans_second.Time],...
            'Algo',trans_first.Algo,...
            'GPSDataPing',concatenate_GPSData(trans_first.GPSDataPing,trans_second.GPSDataPing),...
            'Mode',trans_first.Mode,...
            'AttitudeNavPing',concatenate_AttitudeNavPing(trans_first.AttitudeNavPing,trans_second.AttitudeNavPing),...
            'Params',concatenate_Params(trans_first.Params,trans_second.Params),...
            'Config',trans_first.Config,...
            'Filters',trans_first.Filters);
        

            regions_1=trans_first.Regions;
            regions_2=trans_second.Regions;
            new_bot=concatenate_Bottom(trans_first.Bottom,trans_second.Bottom);
            
            for ir2=1:length(regions_2)
                regions_2(ir2).Idx_pings=regions_2(ir2).Idx_pings+length(trans_first.get_transceiver_pings());
            end    

        trans_out(i).Bottom=new_bot;
 
        trans_out(i).add_region(regions_1);
        trans_out(i).add_region(regions_2);
        
        
    end
else
    error('Cannot concatenate two files with diff frequencies')
end
end