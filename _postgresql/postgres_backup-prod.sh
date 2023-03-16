#!/bin/bash
export PGPASSWORD='wXfrQBjK4XYFY3KH6D2D'
export PGHOST='db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com'
export PGPORT='5432'
export PGUSER='postgres'


psql -d postgres -c "create database tgs_2022_11_09"

pg_dump -Fc tgs > mydb_2022_11_09.sql 
pg_restore -d tgs_2022_11_09 < mydb_2022_11_09.sql

這樣 restore 就可以包含 index

