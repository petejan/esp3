function savingdata(h,rawname,data2aver,Sv2aver,latd2aver,longd2aver,znew2aver,...
    ping_filt,Eping_filt,Nping_filt,foot_radio_filt,SoundVelocity,freq_echo,...
    SampleInterval,hour_filt,min_filt,sec_filt)
x=get(h,'XData');
y=get(h,'YData');
z=get(h,'ZData');
j=1;

temp1=find(isnan(z)~=1);
lat=x(temp1);
lon=y(temp1);
znew=z(temp1);
clear temp1

%[N,E,Z]=LLtoUTM(23 ,lat , lon);

clear x y z i j 

%load Data2aver.mat
clear Z_filt x_filt y_filt
temp=find(data2aver~=0);
datito=data2aver(temp);
data_Sv=Sv2aver(temp);
lati=latd2aver(temp);
longi=longd2aver(temp);
zi=znew2aver(temp);
ping_num=ping_filt(temp);
hour_num=hour_filt(temp);
min_num=min_filt(temp);
sec_num=sec_filt(temp);
E_foot=Eping_filt(temp);
N_foot=Nping_filt(temp);
R_foot=foot_radio_filt(temp);



X1=[lat' lon' znew'];
X2=[lati longi -zi];
[~,Locb] = ismember(X2,X1,'rows');

temp=find(Locb~=0);

[N,E,Z]=deg2utm(lati(temp) , longi(temp));
ENZLALOZTSSVP=cell(1, 12);
ENZLALOZTSSVP{1, 1} = E;
ENZLALOZTSSVP{1, 2} = N;
ENZLALOZTSSVP{1, 3} = Z;
ENZLALOZTSSVP{1, 4} = lati(temp);
ENZLALOZTSSVP{1, 5} = longi(temp);
ENZLALOZTSSVP{1, 6} = -zi(temp);
ENZLALOZTSSVP{1, 7} = datito(temp);
ENZLALOZTSSVP{1, 8} = data_Sv(temp);
ENZLALOZTSSVP{1, 9} = ping_num(temp);
ENZLALOZTSSVP{1, 10} = E_foot(temp);
ENZLALOZTSSVP{1, 11} = N_foot(temp);
ENZLALOZTSSVP{1, 12} = R_foot(temp);
ENZLALOZTSSVP{1, 13} = SoundVelocity;
ENZLALOZTSSVP{1, 14} = freq_echo;
ENZLALOZTSSVP{1, 15} = SampleInterval;
ENZLALOZTSSVP{1, 16} = hour_num(temp);
ENZLALOZTSSVP{1, 17} = min_num(temp);
ENZLALOZTSSVP{1, 18} = sec_num(temp);

bd=find(rawname==char(46))-1;
name_mat_file=strcat(rawname(1:bd),'_flares.mat');
clear bd

[flare_name,path] = uiputfile(['Flare_XXX_' num2str(freq_echo/1e3,'%.0f') 'kHz.mat'],'Save flare as?');

temp=find(flare_name==char(46));

flare_name=flare_name(1:temp-1);
temp=strfind(flare_name,'-');
flare_name(temp)=[];

name_mat_file=fullfile(path,name_mat_file);
% eval([flare_name ' = ENZLALOZTSSVP ;']) ;
vname=flare_name;
if isempty(vname)
    return;
end
eval(sprintf('%s=ENZLALOZTSSVP',flare_name));

if exist(name_mat_file,'file')==0
    save(name_mat_file, vname); 
    
else  
    save(name_mat_file,vname,'-append');
    
end
