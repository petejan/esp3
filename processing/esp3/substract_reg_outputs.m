function  output_diff  = substract_reg_outputs( output_reg_1,output_reg_2)

output_diff=output_reg_1;

if ~all(size(output_reg_1.Sv_mean_lin)==size(output_reg_2.Sv_mean_lin))
    output_diff=[];
    return
else
  
    [N_x,N_y]=size(output_reg_1.Sv_mean_lin);
    
    output_diff.Sv_mean_lin=db2pow(pow2db_perso(output_reg_1.Sv_mean_lin)-pow2db_perso(output_reg_2.Sv_mean_lin));
    output_diff.eint=db2pow(pow2db_perso(output_reg_1.eint)-pow2db_perso(output_reg_2.eint));
    
    output_diff.ABC=zeros(N_y,N_x);
    output_diff.NASC=zeros(N_y,N_x);
end

end

