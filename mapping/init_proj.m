function Proj=init_proj(proj_init,LongLim,LatLim)

proj=m_getproj;
list_proj_str={proj(:).name};
sucess=0;
i=0;
if isempty(proj_init)
    Proj=list_proj_str{1};
    i_proj=0;
else
    Proj=proj_init;
    i_proj=find(strcmp(proj_init,list_proj_str));
end

while sucess==0&&i<length(list_proj_str)
    try
        m_proj(Proj,'long',LongLim,'lat',LatLim);
        sucess=1;
    catch
        i=i+1;
        if i>length(list_proj_str)
            fprintf(1,'Could not find any appropriate projection\n');
            Proj=[];
            return
        end
        fprintf(1,'Can''t use %s projection inside this area... Trying %s\n',Proj,list_proj_str{i});
        Proj=list_proj_str{nanmax(rem(i_proj+i,numel(list_proj_str)),1)};        
    end
end