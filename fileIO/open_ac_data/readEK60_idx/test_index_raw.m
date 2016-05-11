clear all;
close all;

path_f='D:\Docs\Data misc\tan1505\hull\ek60';
%fileN='tan1505-D20150428-T030505.raw';
fileN='tan1505-D20150423-T142040.raw';

profile on;

idx_raw_obj=idx_from_raw(fullfile(path_f,fileN));
[header_idx,data_idx]=data_from_raw_idx_cl(path_f,idx_raw_obj);

[header, data_ekraw] = readEKRaw(fullfile(path_f,fileN),'gps',0,'RawNMEA',1);


profile off;
profile viewer;