function data=init_dataEK60(nb_pings,nb_samples,nb_nmea)
nb_transceivers=length(nb_pings);

for i=1:nb_transceivers
    nb_pings_channel=nb_pings(i);  
    data.pings(i).mode = nan(1,nb_pings_channel);
    data.pings(i).number = nan(1,nb_pings_channel);
    data.pings(i).transducerdepth = nan(1,nb_pings_channel);
    data.pings(i).frequency = nan(1,nb_pings_channel);
    data.pings(i).transmitpower = nan(1,nb_pings_channel);
    data.pings(i).pulselength = nan(1,nb_pings_channel);
    data.pings(i).bandwidth = nan(1,nb_pings_channel);
    data.pings(i).sampleinterval = nan(1,nb_pings_channel);
    data.pings(i).soundvelocity = nan(1,nb_pings_channel);
    data.pings(i).absorptioncoefficient = nan(1,nb_pings_channel);
%     data.pings(i).heave = nan(1,nb_pings_channel);
%     data.pings(i).roll = nan(1,nb_pings_channel);
%     data.pings(i).pitch = nan(1,nb_pings_channel);
%     data.pings(i).temperature = nan(1,nb_pings_channel);
%     data.pings(i).trawlupperdepthvalid = nan(1,nb_pings_channel);
%     data.pings(i).trawlopeningvalid = nan(1,nb_pings_channel);
%     data.pings(i).trawlupperdepth = nan(1,nb_pings_channel);
%     data.pings(i).trawlopening = nan(1,nb_pings_channel);
%     data.pings(i).offset = nan(1,nb_pings_channel);
    data.pings(i).count = nan(1,nb_pings_channel);
    data.pings(i).power=nan(nb_samples(i),nb_pings_channel);
    data.pings(i).alongship_e=nan(nb_samples(i),nb_pings_channel);
    data.pings(i).athwartship_e=nan(nb_samples(i),nb_pings_channel);
    data.pings(i).time= nan(1,nb_pings_channel); 
end

data.NMEA.time= nan(1,nb_nmea);
data.NMEA.string= cell(1,nb_nmea);

