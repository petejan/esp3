function apply_soundspeed(trans_obj,old_c,new_c)

old_range=trans_obj.Data.get_range();
dR_old=nanmean(diff(old_range));
t=2*dR_old/old_c;
dR_new= double(new_c * t / 2);
new_range=(trans_obj.Data.get_samples()-1)*dR_new;
[~,Np]=trans_obj.get_pulse_length();
[TVG_Sp_old,TVG_Sv_old]=computeTVG(old_range,Np);

[TVG_Sp_new,TVG_Sv_new]=computeTVG(new_range,Np);

trans_obj.Data.Range=[new_range(1) new_range(end)];

Sv=trans_obj.Data.get_datamat('sv');
Sp=trans_obj.Data.get_datamat('sp');
Sp_un=trans_obj.Data.get_datamat('spunmatched');

if ~isempty(Sv)
    Sv=Sv+repmat(TVG_Sv_new-TVG_Sv_old,1,size(Sv,2));
    trans_obj.Data.replace_sub_data('sv',Sv);
end
if ~isempty(Sp)
    Sp=Sp+repmat(TVG_Sp_new-TVG_Sp_old,1,size(Sv,2));
    trans_obj.Data.replace_sub_data('sp',Sp);
end
if ~isempty(Sp_un)
    Sp_un=Sp_un+repmat(TVG_Sp_new-TVG_Sp_old,1,size(Sv,2));
    trans_obj.Data.replace_sub_data('spunmatched',Sp_un);
end

