#!/bin/bash
export PGPASSWORD='wXfrQBjK4XYFY3KH6D2D'
export PGHOST='db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com'
export PGPORT='5432'
export PGUSER='postgres'

psql -d postgres -c "revoke connect on database tgs_migration from public"
psql -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_get_activity(NULL::integer) WHERE datid=(SELECT oid from pg_database where datname = 'tgs_migration');"
psql -d postgres -c "drop database if exists tgs_migration"

pg_dump -w tgs --schema-only  -f tmp_bak
psql -d postgres -c "create database tgs_migration"
psql -d tgs_migration -f tmp_bak
psql -d tgs_migration -c "CREATE EXTENSION postgres_fdw;"
psql -d tgs_migration -c "CREATE SERVER tgs_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '$PGHOST', port '$PGPORT', dbname 'tgs');"
psql -d tgs_migration -c "CREATE USER MAPPING FOR PUBLIC SERVER tgs_server OPTIONS (user '$PGUSER', password '$PGPASSWORD')"
psql -d tgs_migration -c "CREATE FOREIGN TABLE old_migration (migration_id character varying(150), product_version character varying(32)) SERVER tgs_server OPTIONS (schema_name 'dbo', table_name '__migrations_history');"
psql -d tgs_migration -c "insert into dbo.__migrations_history select * from old_migration"
psql -d tgs_migration -c "ALTER DEFAULT PRIVILEGES GRANT ALL ON TABLES TO tgs_migration"
psql -d tgs_migration -c "GRANT ALL ON DATABASE tgs_migration TO tgs_migration"
psql -d tgs_migration -c "ALTER DEFAULT PRIVILEGES GRANT REFERENCES, SELECT, UPDATE, DELETE, INSERT ON TABLES TO tgs_migration"
rm tmp_bak




psql -d postgres -c "revoke connect on database tgs from public"
psql -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_get_activity(NULL::integer) WHERE datid=(SELECT oid from pg_database where datname = 'tgs');"
psql -d postgres -c "drop database if exists tgs"



revoke connect on database tgs from public;
SELECT pg_terminate_backend(pid) FROM pg_stat_get_activity(NULL::integer) WHERE datid=(SELECT oid from pg_database where datname = 'tgs');


SELECT pid, pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE datname = current_database() AND pid <> pg_backend_pid();


drop database if exists tgs
