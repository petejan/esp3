function save_regs(layer)

path=layer.PathToFile;
if length(layer.Filename)>1
    file=[layer.Filename{1} '_' layer.Filename{end}];
else
    file=layer.Filename{1};
end

if ~isdir(fullfile(path,'echoanalysisfiles'))
    mkdir(fullfile(path,'echoanalysisfiles'));
end

reg_filename=fullfile(path,'echoanalysisfiles',[file '.mat']);

regfile.SurveyData=layer.SurveyData;

for i=1:length(layer.Frequencies)
    regfile.Regions{i}=layer.Transceivers(i).Regions;
    regfile.Bottom(i)=layer.Transceivers(i).Bottom;
    regfile.Algo{i}=layer.Transceivers(i).Algo;
    regfile.ST{i}=layer.Transceivers(i).ST;
    regfile.Tracks{i}=layer.Transceivers(i).Tracks;
    regfile.Frequencies(i)=layer.Frequencies(i);
    regfile.date=now;
end

save(reg_filename,'regfile');

end