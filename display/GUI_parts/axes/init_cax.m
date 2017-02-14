function [Cax,Type]=init_cax(Fieldname)

switch lower(Fieldname)
    case  'sv'
        Cax=[-70 -35];
        Type='Sv';
    case 'svdenoised'
        Cax=[-70 -35];
        Type='Denoised Sv';
    case 'sp'
        Cax=[-60 -30];
        Type='Sp';
    case 'sp_comp'
        Cax=[-60 -30];
        Type='TS';
    case    'spdenoised'
        Cax=[-60 -30];
        Type='Denoised Sp';
    case  'spunmatched'
        Cax=[-60 -30];
        Type='Sp before match filtering';
    case 'power'
        Cax=[-200 0];
        Type='Power';
    case 'powerunmatched'
        Cax=[-200 0];
        Type='Power Before match Filtering';
    case 'powerdenoised'
        Cax=[-200 0];
        Type='Denoised Power';
    case'y_real'
        Cax=[-200 0];
        Type='Y_real';
    case'y_imag'
        Cax=[-200 0];
        Type='Y_imag';
    case 'singletarget'
        Cax=[-60 -30];
        Type='Single Targets compensated TS';
    case 'snr'
        Cax=[0 30];
        Type='SNR';
    case 'acrossphi'
        Cax=[-180 180];
        Type='Phase Across';
    case 'alongphi'
        Cax=[-180 180];
        Type='Phase Along';
    case 'alongangle'
        Cax=[-10 10];
        Type='Angle Along';
    case 'acrossangle'
        Cax=[-10 10];
        Type='Angle Across';
   case 'fishdensity'
        Cax=[0 30];
        Type='Fish Density';
    otherwise
        Cax=[-Inf Inf];
        Type=Fieldname;
end

end