function [poly_combined,type]=get_combined_poly(region_1,region_2,method)

poly_1=region_1.Poly;
poly_2=region_2.Poly;

switch region_1.Type
    case 'Data'
        switch region_2.Type
            case 'Bad Data'
                method='subtract';
        end
        type=region_1.Type;
    case 'Bad Data'
        switch region_2.Type
            case 'Data'
                method='intersect';
                type=region_2.Type;
            case 'Bad Data'
                type=region_1.Type;
        end
       
end

switch method
    case 'intersect'
        poly_combined=intersect(poly_1,poly_2);
    case 'union'
        poly_combined=union(poly_1,poly_2);
    case 'subtract'
        poly_combined=subtract(poly_1,poly_2);
end

poly_combined.Vertices=round(poly_combined.Vertices);




