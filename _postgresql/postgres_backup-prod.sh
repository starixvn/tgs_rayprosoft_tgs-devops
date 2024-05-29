#!/bin/bash
export PGPASSWORD='4vqMePnsYNRwcxGt'
export PGHOST='db-staging.cglu874fh5rb.ap-east-1.rds.amazonaws.com'
export PGPORT='5432'
export PGUSER='rpdev'


psql -d postgres -c "create database tgs_20240527"

pg_dump -Fc tgsdev > mydb_20240527.sql 
pg_dump -Fc tgs > mydb_2023_05_03.sql 

pg_restore -d tgs_2022_11_09 < mydb_2022_11_09.sql

這樣 restore 就可以包含 index


## for restore
export PGPASSWORD='abcd1234'
export PGHOST='192.168.112.80'
export PGPORT='5432'
export PGUSER='rpdev'
export database="tgsdev"

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
        
		

create extension aws_commons
create extension aws_s3
create extension pg_partman
	
pg_restore -d $database < mydb_20240527.sql
