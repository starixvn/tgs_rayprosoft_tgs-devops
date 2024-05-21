export PGPASSWORD='XXXXXXXXXXXXXXX'
export PGHOST='db-xxxx.xxxxx.ap-east-1.rds.amazonaws.com'
export PGPORT='5432'
export PGUSER='postgres'

psql -d postgres -c "create database tgs_2022_11_09"

pg_dump -Fc tgs > mydb_2023_05_03.sql 

pg_restore -d tgs_2022_11_09 < mydb_2023_05_03.sql

這樣 restore 就可以包含 index


## for restore
export PGPASSWORD='postgres'
export PGHOST='localhost'
export PGPORT='5432'
export PGUSER='postgres'
export database="tgs"

psql -d postgres -c "create database $database"


create user tgs_migration with 
		LOGIN
        SUPERUSER
        INHERIT
        NOCREATEDB
        NOCREATEROLE
        NOREPLICATION
        CONNECTION LIMIT 100
        PASSWORD 'abcd1234';

create user tgs_app with 
		LOGIN
        SUPERUSER
        INHERIT
        NOCREATEDB
        NOCREATEROLE
        NOREPLICATION
        CONNECTION LIMIT 100
        PASSWORD 'abcd1234';
		
create user tgspostgressuprtadmin with 
		LOGIN
        SUPERUSER
        INHERIT
        NOCREATEDB
        NOCREATEROLE
        NOREPLICATION
        CONNECTION LIMIT 10
        PASSWORD 'abcd1234';		

create extension aws_commons
create extension aws_s3
create extension pg_partman
	
pg_restore -d $database < mydb_2023_05_03.sql
