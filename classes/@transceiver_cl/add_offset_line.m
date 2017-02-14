function add_offset_line(trans_obj,line_obj)

range_line=resample_data_v2(line_obj.Range,line_obj.Time,trans_obj.Data.Time);
range_line(isnan(range_line))=0;
line_obj_2=line_cl('Tag',line_obj.Tag,'Range',range_line,'Time',trans_obj.Data.Time,'File_origin',line_obj.File_origin,'UTC_diff',line_obj.UTC_diff);
trans_obj.OffsetLine=line_obj_2;

end