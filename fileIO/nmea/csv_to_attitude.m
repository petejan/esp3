function attitude_full=csv_to_attitude(PathToFile,FileName)
if PathToFile==0
    return;
end
%att_struct=csv2struct(fullfile(PathToFile,FileName));
att_struct=csv2struct_perso(fullfile(PathToFile,FileName));

if all(isfield(att_struct,{'Heading','Heave','Pitch','Roll','Time'}))
 attitude_full=attitude_nav_cl('Heading',att_struct.Heading,'Heave',att_struct.Heave,'Pitch',att_struct.Pitch,'Roll',att_struct.Roll,'Time',att_struct.Time);
elseif all(isfield(att_struct,{'Heading','Heave','Pitch','Roll','Abscissa'}))
     attitude_full=attitude_nav_cl('Heading',att_struct.Heading,'Heave',att_struct.Heave,'Pitch',att_struct.Pitch,'Roll',att_struct.Roll,'Time',att_struct.Abscissa);
elseif all(isfield(att_struct,{'pitch','roll','yaw','datetime'}))
    time=cellfun(@(x) datenum(x,'yyyy-mm-ddTHH:MM:SS'),att_struct.datetime(1:end-1));
    attitude_full=attitude_nav_cl('Yaw',att_struct.yaw,'Pitch',att_struct.pitch,'Roll',att_struct.roll,'Time',time);
else
    attitude_full=[];
end
end