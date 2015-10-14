function obj_out=resample_attitude_nav_data(obj,time)
       

if ~isempty(obj.Roll)
    [heading_pings,time_head]=resample_data(obj.Heading,obj.Time,time);
    [pitch_pings,~]=resample_data(obj.Pitch,obj.Time,time);
    [roll_pings,~]=resample_data(obj.Roll,obj.Time,time);
    [heave_pings,time_att]=resample_data(obj.Heave,obj.Time,time);
    obj_out=attitude_nav_cl('Heading',heading_pings,'Pitch',pitch_pings,'Roll',roll_pings,'Heave',heave_pings,'Time',time);
    
elseif ~isempty(obj.Heading)
    
    [heading_pings,time_head]=resample_data(obj.Heading,obj.Time,time);
    obj_out=attitude_nav_cl('Heading',heading_pings,'Time',time);
else
    obj_out=attitude_nav_cl();

end
        
        
end