clear all;
close all;

path='D:\Docs\Data misc\tan1505\hull\ek60';
fileN='ek60\tan1505-D20150428-T030505.raw';



idx_raw_obj=idx_from_rawEK60(path,fileN);


[header_idx,data_idx]=data_from_raw_idx_cl(path,idx_raw_obj);

%[header, data_ekraw] = readEKRaw(fileN,'gps',0,'RawNMEA',1);

% 
% profile off;
% profile viewer;