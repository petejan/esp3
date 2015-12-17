function regions=create_regions_from_evr(filename,range,timevec)

p = inputParser;

addRequired(p,'filename',@ischar);
addRequired(p,'range',@isnumeric);
addRequired(p,'timevec',@isnumeric);

parse(p,filename,range,timevec);

if exist(filename,'file')==0
    obj=[];
    disp('Cannot find specified .evr file');
    return;
end

reg_evr=read_evr(filename);



Cell_w=10;
Cell_h=10;

nb_reg=1;
Origin='EVR';
Cell_w_unit='pings';
Cell_h_unit='meters';

regions=[];
for i=1:length(reg_evr)
    ID=reg_evr(i).info.reg_id;
    Tag=reg_evr(i).classification;
    Name=reg_evr(i).name;
    switch reg_evr(i).type
        case 0
            Type='Bad Data';
        case 1
            Type='Data';
            % "0" = bad (no data);
            % "1" = analysis;
            % "2" = marker
            % "3" = fishtracks
            % "4" = bad (empty water)
    end
    time_box=[reg_evr(i).bbox.time_start reg_evr(i).bbox.time_end];
    [pings,~]=resample_data_v2(1:length(timevec),timevec,time_box,'Opt','Nearest');

    depth_box=[reg_evr(i).bbox.depth_start reg_evr(i).bbox.depth_end];
    [samples,~]=resample_data_v2(1:length(range),range,depth_box,'Opt','Nearest');

    
    Idx_pings=pings(1):pings(2);
    Idx_r=samples(1):samples(2);
    
    if nansum(isnan(Idx_pings))==length(Idx_pings)
        continue;
    end
    
    switch reg_evr(i).info.r_type
        case 0 %Horizontal region
            Shape='Rectangular';
            Idx_pings=1:length(timevec);
            Reference='Surface';
        case {1,2} %Polygonal region
            Shape='Polygon';
            Reference='Surface';
        case 3 %Rectangular classic
            Shape='Rectangular';
            Reference='Surface';
        case 4 %Vertical Region
            Shape='Rectangular';
            Idx_r=1:length(range);
            Reference='Surface';
        case 5 %Bottom Relative Region
            Shape='Polygon';
            Reference='Bottom';
        case {6,7} %School Detect region
            Shape='Polygon';
            Reference='Surface';
        otherwise %case 9 is for fish track, TODO later...
            continue;
    end
    
    switch Shape
        case 'Rectangular'
            Sv_reg=[];
        case 'Polygon'
            [X_cont,~]=resample_data_v2(1:length(timevec),timevec,reg_evr(i).timestamp,'Opt','Nearest');
            [Y_cont,~]=resample_data_v2(1:length(range),range,reg_evr(i).depth,'Opt','Nearest');
            X_cont=X_cont-Idx_pings(1)+1;
            Y_cont=Y_cont-Idx_r(1)+1;
            [X,Y] = meshgrid(Idx_pings,Idx_r);
            Sv_reg = double(inpolygon(X,Y,X_cont,Y_cont));
            Sv_reg(Sv_reg==0)=nan;
    end
    regions=[regions region_cl(...
        'ID',ID,...
        'Name',Name,...
        'Tag',Tag,...
        'Type',Type,...
        'Idx_pings',Idx_pings,...
        'Idx_r',Idx_r,...
        'Shape',Shape,...
        'Sv_reg',Sv_reg,...
        'Reference',Reference,...
        'Cell_w',Cell_w,...
        'Cell_w_unit',Cell_w_unit,...
        'Cell_h',Cell_h,...
        'Cell_h_unit',Cell_h_unit,...
        'Output',[])];
  
    nb_reg=nb_reg+1;
end

end

