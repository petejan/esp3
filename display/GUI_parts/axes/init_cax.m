function [Cax,Type]=init_cax(Fieldname)

if isempty(Fieldname)
    Cax=[];
    Type='';
    return;
end

switch lower(deblank(Fieldname))
    case 'sv'
        Cax=[-70 -35];
        Type='Sv';
    case 'svdenoised'
        Cax=[-70 -35];
        Type='Denoised Sv';
    case 'sp'
        Cax=[-60 -30];
        Type='TS Unc';
    case 'sp_comp'
        Cax=[-60 -30];
        Type='TS';
    case 'spdenoised'
        Cax=[-60 -30];
        Type='Denoised Sp';
    case 'spunmatched'
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
        Type='ST TS';
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
        Cax=[0 10];
        Type='Fish Density';
    case 'motioncompensation'
        Cax=[0 12];
        Type='Motion Compensation';
    otherwise
        if ~isempty(strfind(lower(Fieldname),'khz'))
            Type=['Sv-' Fieldname];
            Cax=[-10 10];
        else
            Cax=[-200 200];
            Type=Fieldname;
        end
end

end