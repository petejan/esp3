function obj=create_line_from_rbr(filename)

[temp,depth,~,timestamp]=read_rbr(filename);

obj=line_cl('Tag','Imported from rbr','Range',depth,'Time',timestamp-13/24,'File_origin',{filename},'UTC_diff',-13,'Data',temp);
end