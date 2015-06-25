function savingspine(rawname,depth_mean, N_Geo_mean, E_Geo_mean,...
    Zone_Geo_mean,TSdB_mean,...
    SvdB_mean,Lat,Long)
ENLALOZDB=cell(1,8);
ENLALOZDB{1,1}=E_Geo_mean;
ENLALOZDB{1,2}=N_Geo_mean;
ENLALOZDB{1,3}=Zone_Geo_mean;
ENLALOZDB{1,4}=Lat;
ENLALOZDB{1,5}=Long;
ENLALOZDB{1,6}=depth_mean;
ENLALOZDB{1,7}=TSdB_mean;
ENLALOZDB{1,8}=SvdB_mean;

bd=find(rawname==char(46))-1;
name_mat_file=strcat(rawname(1:bd),'_spines.mat');
clear bd

[spine_name,path] = uiputfile(name_mat_file,'Save file as');

temp=find(spine_name==char(46));

spine_name=spine_name(1:temp-1);
temp=strfind(spine_name,'-');
spine_name(temp)=[];

name_mat_file=fullfile(path,name_mat_file);
% eval([spine_name ' = ENZLALOZTSSVP ;']) ;
vname=spine_name;

eval(sprintf('%s=ENLALOZDB',spine_name));

if exist(name_mat_file,'file')==0
    save(name_mat_file, vname); 
    
else  
    save(name_mat_file,vname,'-append');
    
end
