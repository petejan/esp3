
classdef mbs_cl < handle
    properties
        input
        output
        outputFile
        brDir
        fileDir
        rawDir
        crestDir
        cal
        absorbtion
    end
    
    methods
        function rawFile = getRawFile(mbs, i, varargin) % get rawfilename
            % from ifile, if rawfilename is not written in ifile (early
            % surveys, as this was implemented in conversion code later)
            % you need to provide a list of rawfilenames
            if nargin == 3;
                rawFiles = csv2struct(varargin{1});
            end
            mbs.input.data.dfilePath{i,1} = [mbs.rawDir mbs.input.data.dfileDir{i}];
            ifileInfo = get_ifile_info(mbs.input.data.dfilePath{i}, mbs.input.data.dfile(i));    % extract rawfilename from ifile
            if isfield(ifileInfo,'rawFileName')
                rawFile = ifileInfo.rawFileName;
            elseif exist('rawFiles','var')==0
                warning('No rawfilename specified in Ifile, please provide rawFileList!');
                return;
            else                                                            % get rawfilename from list specified
                rawFile = rawFiles.rawfile{rawFiles.dfile==mbs.input.data.dfile(i)};
            end
        end
        
        function printOutput(mbs) % print the whole output on the screen
            % and if defined in mbs.outputFile into a text file
            fids{1} = 1;
            if ~isempty(mbs.outputFile)
                fids{2} = fopen(mbs.outputFile, 'w+');
            end
            
            for i = 1:length(fids);
                fid = fids{i};
                
                %% Header
                fprintf(fid,'title: %s\n', mbs.input.data.title);
                fprintf(fid,'main_species: %s\n', mbs.input.data.main_species);
                fprintf(fid,'voyage: %s\n', mbs.input.data.voyage);
                fprintf(fid,'areas: %s\n', mbs.input.data.areas);
                fprintf(fid,'author: %s\n', mbs.input.data.author);
                fprintf(fid,'created: %s\n', mbs.input.data.created);
                fprintf(fid,'comments: %s\n', mbs.input.data.comments);
                fprintf(fid,'MBS_revision: %s\n', '?');
                fprintf(fid,'MBS_filename: %s\n', '?');
                
                fprintf(fid,'\nnumber_of_strata: %0.f\n', length(unique(mbs.output.regionSum.data(:,2))));
                fprintf(fid,'number_of_transects: %0.f\n', length(unique(cell2mat(mbs.output.regionSum.data(:,3)))));
                fprintf(fid,'number_of_regions: %0.f\n', length(mbs.output.regionSum.data(:,5)));
                
                %% Usage summary
                fprintf(fid,'\n# Usage summary\n');
                fprintf(fid,'processing_completed: %s\n', datestr(now, 'yyyy-mm-ddTHH:MM:SS'));
                fprintf(fid,'computer: %s\n', '?');
                fprintf(fid,'user: %s\n', '?');
                fprintf(fid,'EchoviewMBS_version: %s\n', '?');
                
                %% Stratum Summary
                fprintf(fid,'\n# Stratum Summary\n#snapshot stratum no_transects abscf_mean abscf_sd abscf_wmean abscf_var\n');
                for k = 1:size(mbs.output.stratumSum.data,1)
                    fprintf(fid,'%0.f,%s,%0.f,%.5e,%.5e,%.5e,%.5e\n', mbs.output.stratumSum.data{k,:});
                end
                
                %% Transect summary
                fprintf(fid,'\n# Transect Summary\n#snapshot stratum transect dist vbscf abscf mean_d pings av_speed start_lat start_lon finish_lat finish_lon\n');
                for k = 1:size(mbs.output.transectSum.data,1)
                    fprintf(fid,'%0.f,%s,%0.f,%0.4f,%.5e,%.5e,%0.3f,%0.f,%0.5f,%0.4f,%0.4f,%0.4f,%0.4f\n', mbs.output.transectSum.data{k,:});
                end
                
                %% Sliced Transect Summary
                fprintf(fid,'\n# Sliced Transect Summary\n#snapshot stratum transect slice_size num_slices {latitude longitude slice_abscf}\n');
                for k = 1:size(mbs.output.slicedTransectSum.data,1)
                    tmp = arrayfun(@(x)  cell2mat(arrayfun(@(y) mbs.output.slicedTransectSum.data{k,end-y:end-y}(x),linspace(2,0,3), 'uni', 0)),1:length(mbs.output.slicedTransectSum.data{k,end}), 'uni', 0);  %rearange abscf data to print vertical by vertical cell
                    efstring =  mbs.getStringEorF(mbs.output.slicedTransectSum.data{k,end},',%0.4f,%0.4f', 'before');
                    fprintf(fid,['%0.f,%s,%0.f,%0.f,%0.f'  efstring '\n'], mbs.output.slicedTransectSum.data{k,1:end-3},tmp{:});
                end
                
                %% Region Summary
                fprintf(fid,'\n# Region Summary\n#snapshot stratum transect file region_id ref slice_size good_pings start_d mean_d finish_d av_speed vbscf abscf\n');
                for k = 1:size(mbs.output.regionSum.data,1)
                    fprintf(fid,'%0.f,%s,%0.f,%s,%0.f,%s,%0.f,%0.f,%0.3f,%0.3f,%0.3f,%0.5f,%.5e,%.5e\n', mbs.output.regionSum.data{k,:});
                end
                
                %% Region Summary (abscf by vertical slice)
                fprintf(fid,'\n# Region Summary (abscf by vertical slice)\n#snapshot stratum transect file region_id num_v_slices {transmit_start latitude longitude column_abscf}\n');
                for k = 1:size(mbs.output.regionSum.data,1)
                    tmp = arrayfun(@(x)  cell2mat(arrayfun(@(y)mbs.output.regionSumAbscf.data{k,end-y-1:end-y-1}(x),linspace(3,0,4), 'uni', 0)),1:length(mbs.output.regionSumAbscf.data{k,end-1}), 'uni', 0);  %rearange abscf data to print vertical by vertical cell
                    fprintf(fid,['%0.f,%s,%0.f,%s,%0.f,%0.f,'  repmat('%0.f,%0.4f,%0.4f,%.5e,', 1,size(mbs.output.regionSumAbscf.data{k,end},2)-1) '%0.f,%0.4f,%0.4f,%.5e\n'], mbs.output.regionSumAbscf.data{k,1:end-5},tmp{:});
                end
                
                %% Region vbscf
                fprintf(fid,'\n# Region vbscf\n#snapshot stratum transect file region_id num_h_slices num_v_slices region_vbscf vbscf_values\n');
                for k = 1:size(mbs.output.regionSum.data,1)
                    efstring = mbs.getStringEorF(mbs.output.regionSumVbscf.data{k,9});
                    fprintf(fid,['%0.f,%s,%0.f,%s,%0.f,%0.f,%0.f,%.5e', efstring, '\n'], mbs.output.regionSumVbscf.data{k,:});
                end
                
                if fid ~= 1;
                    fclose(fid);
                end
            end
            
        end
        
         function string = getStringEorF(mbs, input, varargin) % returns a
            % formatted string as fprintf input with %.5e for exponential
            % number and %f for 0.
            if nargin ==4;
                if varargin{2} == 'before'
                    pre =  varargin{1};
                    post = '';
                else
                    post = varargin{1};
                    pre = '';
                end
            else
                pre = '';
                post = '';
            end
            if~isempty(input)
            
            a = find(input~=0);
            b = find(input==0);
            for i = 1:length(a)
                string{a(i)}= [pre ',%.5e' post];
            end
            
            for i = 1:length(b)
                string{b(i)}= [pre ',%.f' post];
            end
            
            string = cell2mat(string);
            else
               string=''; 
            end
        end
        
        
    end
end

