function add_many_to_many(ac_db_filename,t_m2m,k_1,k_2,k_1_val,k_2_val)

try
    dbconn=connect_to_db(ac_db_filename);
    for i=1:length(k_1_val)
        for j=1:length(k_2_val)
            dbconn.insert(t_m2m,{k_1,k_2},{k_1_val(i),k_2_val(j)});
        end
    end
    dbconn.close();
catch err
    disp(err.message);
    warning('add_many_to_many:Error while inserting values');
end

end

