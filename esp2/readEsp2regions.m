function Regions = readEsp2regions(rfile,pingOffset)

fid = fopen(rfile, 'r');
if fid==-1
    Regions=[];
    return;
end
u=fgetl(fid);
uu=fgetl(fid);
uuu=fgetl(fid);
PingCount = str2double(fgetl(fid));
RegionCount = str2double(fgetl(fid));
i =0;
Regions=region_cl.empty(0);

while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    if strfind(tline,'RegionBegin');
        i = i+1;
        tline = fgetl(fid);
        ID = {tline(5:end)};
        tline = fgetl(fid);
        c = strfind(tline,':');
        s = strfind(tline,';');
        Shape = tline(c(1)+2:c(2)-1);
        tmp = tline(c(2)+2:s-1);
        cm = strfind(tmp,',');
        sp = strfind(tmp,' ');
        
  
        x1 = str2double(tmp(1:cm(1)-1));
        y1 = round(str2double(tmp(cm(1)+1:sp-1)));
        x2 = str2double(tmp(sp+1:cm(2)-1));
        y2 = round(str2double(tmp(cm(2)+1:end)));
        
        %Ping_ori=nanmin(x1,x2)+pingOffset;
        %Sample_ori=nanmin(y1,y2);
        
        idx_pings=(nanmin(x1,x2):nanmax(x1,x2))+pingOffset;
        idx_pings(idx_pings>PingCount)=[];
        idx_r=(nanmin(y1,y2):nanmax(y1,y2))+1;
        
        
        if strcmp(Shape,'Polygon');  % get Region Polygon Points: 1st dim ping no, 2nd dim sample no
            tmp = tline(s+1:end);
            cm = strfind(tmp,',');
            sp = strfind(tmp,' ');
            X_cont=nan(1,length(sp));
            Y_cont=nan(1,length(sp));
            
            for j = 1:length(sp);
                X_cont(j) = str2double(tmp(sp(j)+1:cm(j)-1))+1;
                if j==length(sp);
                    Y_cont(j) = round(str2double(tmp(cm(j)+1:end-1)));
                else
                    Y_cont(j) =round(str2double(tmp(cm(j)+1:sp(j+1)-1)));
                end               
            end
        end
        
        switch Shape
            case 'Rectangle'
                Shape='Rectangular';
                Sv_reg=[];
            case 'Polygon'
                Shape='Polygon';
                [X,Y] = meshgrid(idx_pings,idx_r);
                Sv_reg = double(inpolygon(X,Y,X_cont,Y_cont));       
                Sv_reg(Sv_reg==0)=nan;
        end
               
        tline = fgetl(fid);
        Type = tline(13:end);
        tline = fgetl(fid);
        Class = tline(17:end);
        tline = fgetl(fid);
        Author = tline(9:end);
        tline = fgetl(fid);
        Cell_h = str2double(tline(12:end));
        Cell_h_unit='meters';
        tline = fgetl(fid);
        Reference = tline(15:end);
        
                        
        switch Reference
            case 'Bottom Referenced'
                Reference='Bottom';
            case 'Surface Referenced'
                Reference='Surface';
        end
        
        switch Type
            case 'Include'
                Type='Data';
            otherwise
                Type='Bad Data';
        end
        
        tline = fgetl(fid);
        Cell_w = str2double(tline(16:end));
        Cell_w_unit='pings';
        
         Regions(i)=region_cl(...
            'ID',str2double(ID),...
            'Name',Class,...
            'Type',Type,...
            'Idx_pings',idx_pings,...
            'Idx_r',idx_r,...
            'Shape',Shape,...
            'Sv_reg',Sv_reg,...
            'Reference',Reference,...
            'Cell_w',Cell_w,...
            'Cell_w_unit',Cell_w_unit,...
            'Cell_h',Cell_h,...
            'Cell_h_unit',Cell_h_unit,...
            'Output',[]);
    end
end
fclose(fid);
end