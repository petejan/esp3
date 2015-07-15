function list=list_matfiles(layers)

u=0;
for i=1:length(layers)
   for j=1:length(layers(i).Transceivers)
      u=u+1;
       list{u}= layers(i).Transceivers(j).MatfileName;
   end
end

end