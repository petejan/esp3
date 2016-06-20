function [nb_bad_pings,nb_pings,files_out,freq_vec]=get_bad_ping_number_from_bottom_xml(files)

if ~iscell(files)
    files={files};
end

nb_pings_temp=[];
nb_bad_pings_temp=[];
freq_temp=[];
files_temp={};

for i_file=1:length(files)
    
    file_curr=files{i_file};
    [path_f,fileTemp,~]=fileparts(file_curr);
    
    bot_file_curr=fullfile(path_f,'bot_reg',['b_' fileTemp '.xml']);
    if exist(bot_file_curr,'file')==0
        continue;
    end
    
    bottom_xml=parse_bottom_xml(bot_file_curr);
    if ~isempty(bottom_xml)
        for ibot=1:length(bottom_xml)
            freq_temp=[freq_temp bottom_xml{ibot}.Infos.Freq];
            nb_pings_temp=[nb_pings_temp length(bottom_xml{ibot}.Bottom.Tag)];
            nb_bad_pings_temp=[nb_bad_pings_temp nansum(bottom_xml{ibot}.Bottom.Tag==0)];
            files_temp=[files_temp fileTemp];
        end
    end
end

freq_vec=unique(freq_temp);

nb_pings=cell(1,length(freq_vec));
nb_bad_pings=cell(1,length(freq_vec));
files_out=cell(1,length(freq_vec));

for ifreq=1:length(freq_vec)
    idx_freq=(freq_temp==freq_vec(ifreq));
    nb_pings{ifreq}=nb_pings_temp(idx_freq);
    nb_bad_pings{ifreq}=nb_bad_pings_temp(idx_freq);
    files_out{ifreq}=files_temp(idx_freq);
end



end

