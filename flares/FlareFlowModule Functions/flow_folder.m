function flow_folder(ethas,rhow,cp,gamma,kcond,rhoG0,...
    Pst0,g,fun,r,sigma,temp,Sal)

%     RisePar = 'Woolf93'            => Only Dirty
%     RisePar = 'Woolf & Thorpe91'   => Only Dirty
%     RisePar = 'Leifer'
%     RisePar = 'Mendelson'          => Only Clean; only for r>rc.
%     RisePar = 'Leifer&Patro'                 Continental Shelf Research, Accepted
 
ris_speed_c(1,:)=(buoyvel(r*100,temp,0,...
    'Leifer',Sal ))/100;
ris_speed_c(2,:)=(buoyvel(r*100,temp,0,...
    'Mendelson',Sal ))/100;
ris_speed_c(3,:)=(buoyvel(r*100,temp,0,...
    'Leifer&Patro',Sal ))/100;

ris_speed_d(1,:)=(buoyvel(r*100,temp,1,...
    'Leifer',Sal ))/100;
ris_speed_d(2,:)=(buoyvel(r*100,temp,1,...
    'Leifer&Patro',Sal ))/100;
ris_speed_d(3,:)=(buoyvel(r*100,temp,1,...
    'Woolf93',Sal ))/100;
ris_speed_d(4,:)=(buoyvel(r*100,temp,1,...
    'Woolf & Thorpe91',Sal ))/100;

dname = uigetdir(pwd);
filename=dir(strcat(dname,'\*.mat'));
files_number=size(filename,1);

for k=1:files_number

filename_w_path = strcat(dname,'\',filename(k).name);
flare = load(filename_w_path);
flarenames = fieldnames(flare);
structSize = length(flarenames);
 
E_mean=NaN(structSize,1);
N_mean=NaN(structSize,1);
N_mean_foot=NaN(structSize,1);
E_mean_foot=NaN(structSize,1);
Z_mean=NaN(structSize,1);
seaf_foot_radius=NaN(structSize,1);
TSgeomean=NaN(structSize,1);
K_c=NaN(structSize,3);
K_d=NaN(structSize,4);
total_flow_c=NaN(structSize,3);
total_flow_d=NaN(structSize,4);

for i=1:structSize

    temp_flare_name=strcat('flare.',flarenames{i});
    mat=eval(temp_flare_name);
    N_mean(i)=geomean(mat{1});
    E_mean(i)=geomean(mat{2});
    Z_mean(i)=geomean(-mat{6});
    TSgeomean(i)=10*log10(geomean(10.^(mat{7}/10)));
    N_mean_foot(i)=geomean(mat{10});
    E_mean_foot(i)=geomean(mat{11});
    seaf_foot_radius(i)=geomean(mat{12});
    sample_interval=mat{15};
    cw=mat{13};
    freq=mat{14};

    for j=1:3
        
        K_c(i,j)=calculates_K(Z_mean(i),cw,ethas,rhow,cp,gamma,kcond,rhoG0,...
            Pst0,g,freq,fun,r,ris_speed_c(j,:),sample_interval,sigma);
        
        total_flow_c(i,j)=(6e7)*K_c(i,j)*10.^(TSgeomean(i)/10);

    end
    
    clear j
    
    for j=1:4
        
        K_d(i,j)=calculates_K(Z_mean(i),cw,ethas,rhow,cp,gamma,kcond,rhoG0,...
            Pst0,g,freq,fun,r,ris_speed_d(j,:),sample_interval,sigma);
        
        total_flow_d(i,j)=(6e7)*K_d(i,j)*10.^(TSgeomean(i)/10);

    end
    
     
end

Info_matrix1=[E_mean N_mean Z_mean TSgeomean E_mean_foot N_mean_foot ...
    seaf_foot_radius K_c K_d...
    total_flow_c total_flow_d];

n=1;
m=1;
for i=1:structSize
    for j=1:structSize
        if (E_mean(i)~=E_mean(j)) && (N_mean(i)~=N_mean(j)) && (j>i)
            dist_flares(n)=sqrt((E_mean(i)-E_mean(j))^2+(N_mean(i)-N_mean(j))^2);
            aver_radius=(seaf_foot_radius(i)+seaf_foot_radius(j))/2;
            if (dist_flares(n)<2*aver_radius) && TSgeomean(i)>TSgeomean(j)
                index_weak(m)=j;
                m=m+1;
            elseif (dist_flares(n)<2*aver_radius) && TSgeomean(j)>TSgeomean(i)
                index_weak(m)=i;
                m=m+1;
            end
                n=n+1;
        end
    end
end
clc
Info_matrix2=Info_matrix1;
if exist('index_weak','var')
    Info_matrix2(index_weak,:)=[];
    clear index_weak
else
    Info_matrix2=NaN;
end

output_filename=filename(k).name(1:(find(filename(k).name==char(46))-1));
output_filename1=strcat(dname,'/',output_filename,'.flow');
output_filename2=strcat(dname,'/',output_filename,'_no_overl.flow');

dlmwrite(output_filename1,...
    Info_matrix1,...
    'delimiter','\t','precision','%.6f')

    if isnan(sum(Info_matrix2))~=1
        dlmwrite(output_filename2,...
        Info_matrix2,...
        'delimiter','\t','precision','%.6f')
    end


end