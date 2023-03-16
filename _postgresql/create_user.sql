 create user gatus with 
		LOGIN
        NOSUPERUSER
        INHERIT
        NOCREATEDB
        NOCREATEROLE
        NOREPLICATION
        CONNECTION LIMIT 10
        PASSWORD '1q2w3e4r';
        
        
    GRANT CONNECT ON DATABASE gatus_prod TO gatus_staging ;
	
	ALTER DATABASE gatus_staging OWNER TO gatus_staging;
	
	REASSIGN OWNED BY postgres TO gatus_prod;
	
	
    GRANT USAGE ON SCHEMA public TO rpdev ;
    GRANT ALL ON ALL TABLES IN SCHEMA dbo,bet,log,report TO rpdev ;
    GRANT ALL ON ALL SEQUENCES IN SCHEMA dbo,bet,log,report TO rpdev ;
    GRANT ALL ON ALL FUNCTIONS IN SCHEMA dbo,bet,log,report TO rpdev ;
    
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO sentry_read;