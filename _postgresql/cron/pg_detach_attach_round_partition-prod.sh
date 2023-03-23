#!/bin/bash
export PGHOST='db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com'
export PGUSER='postgres'
export PGPASSWORD='wXfrQBjK4XYFY3KH6D2D'
export PGDATABASE='tgs'
export table=rounds_p$(date +%Y_%m_%d -d '-92 days')
export start_date=$(date +%Y-%m-%d -d '-92 days')
export end_date=$(date +%Y-%m-%d -d '-91 days')
echo "table=$table"
echo "start_date=$start_date"
echo "end_date=$end_date"

echo "alter table bet.rounds detach partition bet.$table;"

psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "alter table bet.rounds detach partition bet.$table;"

echo "alter table bet.$table set schema backup;"

psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "alter table bet.$table set schema backup;"
psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "alter table backup.rounds attach partition backup.$table for values from ('$start_date') to ('$end_date');"
psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "insert into bet.rounds select * from backup.$table where not (status=2 and client_status !=1);"
psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "delete FROM bet.round_details d using backup.$table d2 where  d.round_id = d2.id and d2.created_on >='$start_date' and d2.created_on < '$end_date';"
psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "vacuum VERBOSE analyze bet.round_details;"
