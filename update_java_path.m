function update_java_path(main_path)
jpath=fullfile(main_path,'java');
jars=dir(jpath);
java_dyn_path=javaclasspath('-dynamic');
for ij=length(jars)-1:1
   if ~jars(ij).isdir 
      [~,~,fileext]=fileparts(jars(ij).name); 
      if ~any(strcmp(java_dyn_path,fullfile(jpath,jars(ij).name)))&&isfile(fullfile(jpath,jars(ij).name))
          if strcmpi(fileext,'.jar')
              javaaddpath(fullfile(jpath,jars(ij).name));
              fprintf('%s added to java path\n',jars(ij).name);
          end
      end
   end
end