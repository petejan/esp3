function attitude_full=csv_to_attitude(PathToFile,FileName)

%att_struct=csv2struct(fullfile(PathToFile,FileName));
att_struct=csv2struct_bis(fullfile(PathToFile,FileName));
if nansum(isfield(att_struct,{'Heading','Heave','Pitch','Roll','Time'}))==length(fieldnames(att_struct))
 attitude_full=attitude_nav_cl('Heading',att_struct.Heading,'Heave',att_struct.Heave,'Pitch',att_struct.Pitch,'Roll',att_struct.Roll,'Time',att_struct.Time);
elseif nansum(isfield(att_struct,{'Heading','Heave','Pitch','Roll','Abscissa'}))==length(fieldnames(att_struct))
     attitude_full=attitude_nav_cl('Heading',att_struct.Heading,'Heave',att_struct.Heave,'Pitch',att_struct.Pitch,'Roll',att_struct.Roll,'Time',att_struct.Abscissa);
else
    attitude_full=[];
end
end