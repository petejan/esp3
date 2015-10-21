function [r_ray,t_ray,z_ray,beta_ray]=compute_acoustic_ray_path(z,c,r_ray,t_ray,z_ray,beta_ray,T)

[z,ia,ib] = unique(z);

if size(z,1)==1
    c=c(ia);
else
    c=c(ib);
end

[z,idx_sort]=sort(z);
c=c(idx_sort);

g_down=(c(2:end)-c(1:end-1))./(z(2:end)-z(1:end-1));
g_down=[g_down g_down(end)];

g_up=-(c(1:end-1)-c(2:end))./(z(1:end-1)-z(2:end));
g_up=[g_up(1) g_up];
    
if beta_ray>0
    g=g_down;
else
    g=g_up;
end

xi=(cos(beta_ray(1))/c(1));

while t_ray(end)<=T
    %t_ray(end)
    [~,idx]=nanmin(abs(z_ray(end)-z));
    
    i=length(r_ray);
    
    if beta_ray(i)<0
        idx_plus=nanmax(idx-1,1);
    elseif beta_ray(i)>0
        idx_plus=nanmin(idx+1,length(z));
    else
        idx_plus=idx;
    end
    
    
    if idx==idx_plus&&idx~=1
        return;
    end
    
    if xi==0 %case where the ray is propagating vertically
        beta_ray(i+1)=beta_ray(i);
        r_ray(i+1)=r_ray(idx);
        t_ray(i+1)=t_ray(i)+(g(idx))*log(c(idx_plus)/c(idx)*(1+sqrt(1-xi^2*c(idx)^2))/(1+sqrt(1-xi^2*c(idx_plus)^2)));
        z_ray(i+1)=z(idx_plus);
    else
        
        if idx_plus==1&&idx==1 %case where it hits the surface
            if g(idx)==0%case where velocity stays the same
                beta_ray(i+1)=-beta_ray(i);
                r_ray(i+1)=r_ray(i)+(z(2)-z(1)/tan(beta_ray(i+1)));
                t_ray(i+1)=t_ray(i)+((z(2)-z(1))/c(1));
                z_ray(i+1)=z(1);                
                if beta_ray(i+1)>0
                    g=g_down;
                else
                    g=g_up;
                end
            else
                beta_ray(i+1)=pi/2-(beta_ray(i)-pi/2);
                r_ray(i+1)=r_ray(i)+(r_ray(i)-r_ray(i-1));
                t_ray(i+1)=t_ray(i)+(t_ray(i)-t_ray(i-1));
                z_ray(i+1)=z(1);
                if beta_ray(i+1)>0
                    g=g_down;
                else
                    g=g_up;
                end
            end
            
        else
            if g(idx)==0%case where velocity stays the same
                beta_ray(i+1)=beta_ray(i);
                r_ray(i+1)=r_ray(i)+((z(idx_plus)-z(idx))/tan(beta_ray(i+1)));
                t_ray(i+1)=t_ray(i)+((z(idx_plus)-z(idx))/c(idx));
                z_ray(i+1)=z(idx_plus);
            else
                if (xi*c(idx_plus))^2<1
                    beta_ray(i+1)=sign(beta_ray(i))*acos(c(idx_plus)*xi);
                    r_ray(i+1)=r_ray(i)+(1/(xi*g(idx))*(sqrt(1-xi^2*c(idx)^2)-sqrt(1-xi^2*c(idx_plus)^2)));
                    t_ray(i+1)=t_ray(i)+1/(g(idx))*log(c(idx_plus)/c(idx)*(1+sqrt(1-xi^2*c(idx)^2))/(1+sqrt(1-xi^2*c(idx_plus)^2)));
                    z_ray(i+1)=z(idx_plus);
                    
                else  %case where the ray got to the critical angle
                    beta_ray(i+1)=-beta_ray(i);
                    xi=(cos(beta_ray(i+1))/c(idx));
                    r_ray(i+1)=r_ray(i)+2/(xi*g(idx))*(sqrt(1-xi^2*c(idx)^2));
                    t_ray(i+1)=t_ray(i)+2/(g(idx))*log(1/(c(idx)*abs(xi))*(1+sqrt(1-xi^2*c(idx)^2)));
                    z_ray(i+1)=z(nanmax(idx-1,1));
                    
                    if beta_ray(i+1)>0
                        g=g_down;
                    else
                        g=g_up;
                    end
                end
            end
        end
        
    end
    
    
end

end