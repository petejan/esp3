classdef mbs_cl < handle
    properties
        Header
        Input
        Output
        OutputFile
    end
    
    methods
        function obj=mbs_cl(varargin)
            
            p = inputParser;
            
            addParameter(p,'Header',mbs_header_cl(),@(obj) isa(obj,'mbs_header_cl'));
            addParameter(p,'Input',mbs_input_cl(),@(obj) isa(obj,'mbs_input_cl'));
            addParameter(p,'Output',mbs_output_cl(),@(obj) isa(obj,'mbs_Output_cl'));
            addParameter(p,'OutputFile',fullfile(pwd,'mbs_run.txt'),@ischar);
            
            parse(p,varargin{:});
            
            props=fieldnames(p.Results);
            
            for i=1:length(props)
                if size(p.Results.(props{i}),2)==1
                    obj.(props{i})=p.Results.(props{i});
                else
                    obj.(props{i})=p.Results.(props{i})';
                end
            end
            
        end
        
        function printOutput(mbs) % print the whole Output on the screen
            % and if defined in mbs.OutputFile into a text file
            fids{1} = 1;
            if ~isempty(mbs.OutputFile)
                fids{2} = fopen(mbs.OutputFile, 'w+');
            end
            
            for i = 1:length(fids);
                fid = fids{i};
                
                %% Header
                fprintf(fid,'title: %s\n', mbs.Header.title);
                fprintf(fid,'main_species: %s\n', mbs.Header.main_species);
                fprintf(fid,'voyage: %s\n', mbs.Header.voyage);
                fprintf(fid,'areas: %s\n', mbs.Header.areas);
                fprintf(fid,'author: %s\n', mbs.Header.author);
                fprintf(fid,'created: %s\n', mbs.Header.created);
                fprintf(fid,'comments: %s\n', mbs.Header.comments);
                fprintf(fid,'MBS_revision: %s\n', '');
                fprintf(fid,'MBS_filename: %s\n', '');
                
                fprintf(fid,'\nnumber_of_strata: %0.f\n', size(mbs.Output.stratumSum.Data,1));
                fprintf(fid,'number_of_transects: %0.f\n', size(mbs.Output.transectSum.Data,1));
                fprintf(fid,'number_of_regions: %0.f\n', size(mbs.Output.regionSum.Data,1));
                
                %% Usage summary
                fprintf(fid,'\n# Usage summary\n');
                fprintf(fid,'processing_completed: %s\n', datestr(now, 'yyyy-mm-ddTHH:MM:SS'));
                fprintf(fid,'computer: %s\n', '?');
                fprintf(fid,'user: %s\n', '?');
                fprintf(fid,'MBS_version: %s\n', '?');
                
                %% Stratum Summary
                fprintf(fid,'\n# Stratum Summary\n#snapshot stratum no_transects abscf_mean abscf_sd abscf_wmean abscf_var\n');
                for k = 1:size(mbs.Output.stratumSum.Data,1)
                    fprintf(fid,'%0.f,%s,%0.f,%.5e,%.5e,%.5e,%.5e\n', mbs.Output.stratumSum.Data{k,:});
                end
                
                %% Transect summary
                fprintf(fid,'\n# Transect Summary\n#snapshot stratum transect dist vbscf abscf mean_d pings av_speed start_lat start_lon finish_lat finish_lon\n');
                for k = 1:size(mbs.Output.transectSum.Data,1)
                    fprintf(fid,'%0.f,%s,%0.f,%0.4f,%.5e,%.5e,%0.3f,%0.f,%0.5f,%0.4f,%0.4f,%0.4f,%0.4f\n', mbs.Output.transectSum.Data{k,:});
                end
                
                %% Sliced Transect Summary
                fprintf(fid,'\n# Sliced Transect Summary\n#snapshot stratum transect slice_size num_slices {latitude longitude slice_abscf}\n');
                for k = 1:size(mbs.Output.slicedTransectSum.Data,1)
                    tmp = arrayfun(@(x)  cell2mat(arrayfun(@(y) mbs.Output.slicedTransectSum.Data{k,end-y:end-y}(x),linspace(2,0,3), 'uni', 0)),1:length(mbs.Output.slicedTransectSum.Data{k,end}), 'uni', 0);  %rearange abscf Data to print vertical by vertical cell
                    efstring =  mbs.getStringEorF(mbs.Output.slicedTransectSum.Data{k,end},',%0.4f,%0.4f', 'before');
                    fprintf(fid,['%0.f,%s,%0.f,%0.f,%0.f'  efstring '\n'], mbs.Output.slicedTransectSum.Data{k,1:end-3},tmp{:});
                end
                
                %% Region Summary
                fprintf(fid,'\n# Region Summary\n#snapshot stratum transect file region_id ref slice_size good_pings start_d mean_d finish_d av_speed vbscf abscf\n');
                for k = 1:size(mbs.Output.regionSum.Data,1)
                    fprintf(fid,'%0.f,%s,%0.f,%s,%0.f,%s,%0.f,%0.f,%0.3f,%0.3f,%0.3f,%0.5f,%.5e,%.5e\n', mbs.Output.regionSum.Data{k,:});
                end
                
                %% Region Summary (abscf by vertical slice)
                fprintf(fid,'\n# Region Summary (abscf by vertical slice)\n#snapshot stratum transect file region_id num_v_slices {transmit_start latitude longitude column_abscf}\n');
                for k = 1:size(mbs.Output.regionSum.Data,1)
                    tmp = arrayfun(@(x)  cell2mat(arrayfun(@(y)mbs.Output.regionSumAbscf.Data{k,end-y-1:end-y-1}(x),linspace(3,0,4), 'uni', 0)),1:length(mbs.Output.regionSumAbscf.Data{k,end-1}), 'uni', 0);  %rearange abscf Data to print vertical by vertical cell
                    fprintf(fid,['%0.f,%s,%0.f,%s,%0.f,%0.f,'  repmat('%0.f,%0.4f,%0.4f,%.5e,', 1,size(mbs.Output.regionSumAbscf.Data{k,end},2)-1) '%0.f,%0.4f,%0.4f,%.5e\n'], mbs.Output.regionSumAbscf.Data{k,1:end-5},tmp{:});
                end
                
                %% Region vbscf
                fprintf(fid,'\n# Region vbscf\n#snapshot stratum transect file region_id num_h_slices num_v_slices region_vbscf vbscf_values\n');
                for k = 1:size(mbs.Output.regionSum.Data,1)
                    efstring = mbs.getStringEorF(mbs.Output.regionSumVbscf.Data{k,9});
                    fprintf(fid,['%0.f,%s,%0.f,%s,%0.f,%0.f,%0.f,%.5e', efstring, '\n'], mbs.Output.regionSumVbscf.Data{k,:});
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