function sph=get_sph_params(sph_name)

switch sph_name
    case 'WC38.1mm'
        
        sph.radius=0.0381/2;
        sph.lont_c=6853;
        sph.trans_c=4171;
        sph.rho=14900;
        sph.rho_water=1025;
    case'WC64mm'
        
        sph.radius=0.064/2;
        sph.lont_c=6853;
        sph.trans_c=4171;
        sph.rho=14900;
        sph.rho_water=1025;
        
end