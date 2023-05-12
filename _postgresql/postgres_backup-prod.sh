#!/bin/bash
export PGPASSWORD='XXXXXXXXXXXXXXX'
export PGHOST='db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com'
export PGPORT='5432'
export PGUSER='postgres'


psql -d postgres -c "create database tgs_2022_11_09"

pg_dump -Fc tgs > mydb_2022_11_09.sql 
pg_dump -Fc tgs > mydb_2023_05_03.sql 

pg_restore -d tgs_2022_11_09 < mydb_2022_11_09.sql

這樣 restore 就可以包含 index


## for restore
export PGPASSWORD='abcd1234'
export PGHOST='192.168.50.19'
export PGPORT='5432'
export PGUSER='postgres'
export database="tgs_2023_05_03_test"

psql -d postgres -c "create database $database"


 create user tgspostgressuprtadmin with 
		LOGIN
        SUPERUSER
        INHERIT
        NOCREATEDB
        NOCREATEROLE
        NOREPLICATION
        CONNECTION LIMIT 10
        PASSWORD 'abcd1234';
        
		
		
pg_restore -d $database < mydb_2023_05_03.sql
