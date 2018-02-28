        function print_output(surv_obj,file) % print the whole SurvOutput on the screen
            % and if defined in surv_obj.SurvOutput into a text file

            fids = fopen(file, 'w');
            for i = 1:length(fids)
                
                fid = fids(i);
                
                %% Header
                fprintf(fid,'title: %s\n', surv_obj.SurvInput.Infos.Title);
                fprintf(fid,'main_species: %s\n', surv_obj.SurvInput.Infos.Main_species);
                fprintf(fid,'voyage: %s\n', surv_obj.SurvInput.Infos.Voyage);
                fprintf(fid,'survey name: %s\n', surv_obj.SurvInput.Infos.SurveyName);
                fprintf(fid,'areas: %s\n', surv_obj.SurvInput.Infos.Areas);
                fprintf(fid,'author: %s\n', surv_obj.SurvInput.Infos.Author);
                fprintf(fid,'created: %s\n', surv_obj.SurvInput.Infos.Created);
                fprintf(fid,'comments: %s\n', surv_obj.SurvInput.Infos.Comments);

                
                fprintf(fid,'\nnumber_of_strata: %0.f\n', length(surv_obj.SurvOutput.stratumSum.snapshot));
                fprintf(fid,'number_of_transects: %0.f\n', length(surv_obj.SurvOutput.transectSum.snapshot));
                fprintf(fid,'number_of_regions: %0.f\n', length(surv_obj.SurvOutput.regionSum.snapshot));
                
                %% Usage summary
                fprintf(fid,'\n# Usage summary\n');
                fprintf(fid,'processing_completed: %s\n', datestr(now, 'yyyy-mm-ddTHH:MM:SS'));
                [~,cmp_out]=system('echo %computername%');
                fprintf(fid,'computer: %s\n',cmp_out);
                [~,usr_out]=system('echo %username%');
                fprintf(fid,'user: %s\n', usr_out);
                
                %% Stratum Summary              
                str=surv_obj.SurvOutput.sprint_stratumSum();
                fwrite(fid,str);
  
                %% Transect summary
                str=surv_obj.SurvOutput.sprint_transectSum();
                fwrite(fid,str);
                
                %% Sliced Transect Summary
                str=surv_obj.SurvOutput.sprint_slicedTransectSum();
                fwrite(fid,str);
                
                %% Region Summary
                str=surv_obj.SurvOutput.sprint_regionSum();
                fwrite(fid,str);
                
                %% Region Summary (abscf by vertical slice)
                str=surv_obj.SurvOutput.sprint_regionSumAbscf();
                fwrite(fid,str);
                 
                %% Region vbscf
                str=surv_obj.SurvOutput.sprint_regionSumVbscf();
                fwrite(fid,str);
                
                if fid~=1
                    fclose(fid);
                end
            end
            
        end