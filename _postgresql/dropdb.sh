#!/bin/bash
export PGPASSWORD='abcd1234'
psql -h 192.168.50.111 -p 5432 -U rpdev -d postgres -c "revoke connect on database $1 from public"
psql -h 192.168.50.111 -p 5432 -U rpdev -d postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) from pg_stat_activity where pg_stat_activity.datname='$1'"
psql -h 192.168.50.111 -p 5432 -U rpdev -d postgres -c "drop database if exists $1"