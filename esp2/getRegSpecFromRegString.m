function regout = getRegSpecFromRegString(Regs)

i= 0;
r = strtrim(Regs);
while 1
    i = i+1;
    [regX, re] =  strtok(r, ')');
    [t,r]=strtok(regX, '(');

    regout(i).id  = str2double(t);
    regout(i).spec = r(2:end);

    in =  strfind(regout(i).spec, ',');
    if isempty(in);
        depths = regout(i).spec;
        slices = [];
    else
        depths = regout(i).spec{i}(1:in-1);
        slices = regout(i).spec(in+1:end);
    end
    if ~isempty(depths)
        ix =  strfind(depths, '-');
        sd = str2double(depths(1:ix-1));
        fd = str2double(depths(ix+1:end));
    else
        sd = 0; fd = Inf;
    end
    if ~isempty(slices)
        ix =  strfind(slices, '-');
        ss = str2double(slices(1:ix-1));
        fs = str2double(slices(ix+1:end));
    else
        ss = 0; fs = Inf;
    end
    if isempty(sd); sd = 0; end
    if isempty(fd); fd = Inf; end
    if isempty(ss); ss = 0; end
    if isempty(fs); fs = Inf; end
    regout(i).startDepth = sd;
    regout(i).finishDepth = fd;
    regout(i) .startSlice= ss;
    regout(i).finishSlice = fs;
    regout(i).name = ['Region' num2str(regout(i).id)];
	regout(i).unique_id=[];
    if re == ')' ; break; end
end
end



