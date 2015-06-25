 function reg = getRegSpecFromRegString(Regs) % get region
            % specification info from mbs input and writes it into a
            % structure for all Regions containing start/finish Depth and
            % Slice. Like in esp2 only slices which fall entirely within
            % these ranges will be included in the MBS analysis.
            i= 0;
            rem = strtrim(Regs);
            while 1
                i = i+1;
                [regX, rem] =  strtok(rem, ')');
                [t r] = strtok(regX, '(');
                reg.id(i)  = str2num(t);
                reg.spec{i} = r(2:end);
                in =  strfind(reg.spec{i}, ',');
                if isempty(in);
                    depths = reg.spec{i};
                    slices = [];
                else
                    depths = reg.spec{i}(1:in-1);
                    slices = reg.spec{i}(in+1:end);
                end
                if ~isempty(depths)
                    ix =  strfind(depths, '-');
                    sd = str2num(depths(1:ix-1));
                    fd = str2num(depths(ix+1:end));
                else
                    sd = NaN; fd = NaN;
                end
                if ~isempty(slices)
                    ix =  strfind(slices, '-');
                    ss = str2num(slices(1:ix-1));
                    fs = str2num(slices(ix+1:end));
                else
                    ss = NaN; fs = NaN;
                end
                if isempty(sd); sd = NaN; end
                if isempty(fd); fd = NaN; end
                if isempty(ss); ss = NaN; end
                if isempty(fs); fs = NaN; end
                reg.startDepth(i) = sd;
                reg.finishDepth(i) = fd;
                reg.startSlice(i) = ss;
                reg.finishSlice(i) = fs;
                reg.name{i} = ['Region' num2str(reg.id(i))];
                if rem == ')' ; break; end
            end
        end
        
      