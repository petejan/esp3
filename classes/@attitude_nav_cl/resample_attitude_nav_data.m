function obj_out=resample_attitude_nav_data(obj,time)
       

if ~isempty(obj.Roll)
    heading_pings=resample_data_v2(obj.Heading,obj.Time,time,'Type','Angle');
   pitch_pings=resample_data_v2(obj.Pitch,obj.Time,time,'Type','Angle');
    roll_pings=resample_data_v2(obj.Roll,obj.Time,time,'Type','Angle');
    heave_pings=resample_data_v2(obj.Heave,obj.Time,time,'Type','Angle');
    obj_out=attitude_nav_cl('Heading',heading_pings,'Pitch',pitch_pings,'Roll',roll_pings,'Heave',heave_pings,'Time',time);
    
elseif ~isempty(obj.Heading)
    
    heading_pings=resample_data_v2(obj.Heading,obj.Time,time,'Type','Angle');
    obj_out=attitude_nav_cl('Heading',heading_pings,'Time',time);
else
    obj_out=attitude_nav_cl.empty();

end
        
        
end