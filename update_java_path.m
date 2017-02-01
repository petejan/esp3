function update_java_path(main_path)
jpath=fullfile(main_path,'java');
jars=dir(jpath);

for ij=1:length(jars)
   if ~jars(ij).isdir 
      [~,~,fileext]=fileparts(jars(ij).name);    
      if strcmpi(fileext,'.jar')    
          javaaddpath(fullfile(jpath,jars(ij).name));
          fprintf('%s added to java path\n',jars(ij).name);
      end
   end
end