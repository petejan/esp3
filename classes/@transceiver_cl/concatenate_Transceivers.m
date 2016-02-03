function trans_out=concatenate_Transceivers(trans_1,trans_2)
if length(trans_1)==length(trans_2)
    for i=1:length(trans_1)
        trans_out(i)=transceiver_cl('Data',concatenate_Data(trans_1(i).Data,trans_2(i).Data),...
            'Algo',trans_1(i).Algo,...
            'GPSDataPing',concatenate_GPSData(trans_1(i).GPSDataPing,trans_2(i).GPSDataPing),...
            'Mode',trans_1(i).Mode,...
            'AttitudeNavPing',concatenate_AttitudeNavPing(trans_1(i).AttitudeNavPing,trans_2(i).AttitudeNavPing),...
            'Params',trans_1(i).Params,...
            'Config',trans_1(i).Config,...
            'Filters',trans_1(i).Filters);
        
        if trans_1(i).Data.Time(1)>=trans_2(i).Data.Time(end)
            regions_2=trans_1(i).Regions;
            regions_1=trans_2(i).Regions;
            new_bot=concatenate_Bottom(trans_2(i).Bottom,trans_1(i).Bottom);
            IdxBad=[trans_2(i).IdxBad; trans_1(i).IdxBad+length(trans_2(i).Data.Number)];
            for ir2=1:length(regions_2)
                regions_2(ir2).Idx_pings=regions_2(ir2).Idx_pings+length(trans_2(i).Data.Number);
            end
        else
            regions_1=trans_1(i).Regions;
            regions_2=trans_2(i).Regions;
            new_bot=concatenate_Bottom(trans_1(i).Bottom,trans_2(i).Bottom);
            IdxBad=[trans_1(i).IdxBad; trans_2(i).IdxBad+length(trans_1(i).Data.Number)];
            for ir2=1:length(regions_2)
                regions_2(ir2).Idx_pings=regions_2(ir2).Idx_pings+length(trans_1(i).Data.Number);
            end    
        end
        trans_out(i).setBottomIdxBad(new_bot,IdxBad);
 
        trans_out(i).add_region(regions_1);
        trans_out(i).add_region(regions_2);
        
        
    end
else
    error('Cannot concatenate two files with diff frequencies')
end
end