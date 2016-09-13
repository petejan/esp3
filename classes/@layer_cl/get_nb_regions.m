function nb_reg=get_nb_regions(layer_obj)

nb_trans=length(layer_obj.Transceivers);
nb_reg=zeros(1,nb_trans);
for i=1:nb_trans
    nb_reg(i)=length(layer_obj.Transceivers(i).Regions);
end

end