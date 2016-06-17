function obj=create_line_from_evl(filename)

[timestamp,depth]=read_evl(filename);

obj=line_cl('Tag','Imported from EVL','Range',depth,'Time',timestamp,'File_origin',filename);
end