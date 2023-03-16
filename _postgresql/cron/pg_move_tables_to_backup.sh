#!/bin/bash
# bash pg_move_tables_to_backup.sh tgsstaging $(date -d "-$ndate day" +%Y_%m_%d --date="-370 day")
# 0 0 * * * root /bin/sh /home/ubuntu/jobs/pg_move_tables_to_backup.sh tgsstaging $(date -d "-$ndate day" +%Y_%m_%d --date="-366 day")

MoveTables() {
    PGHOST='db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com'
    PGUSER='postgres'

    schema_to_be_deleted=$5
    table_to_be_deleted="${6}_p${2}"

    echo "table=${table_to_be_deleted}"

   echo "CREATE TABLE IF NOT EXISTS backup.${6}_p${2} PARTITION OF backup.${6} FOR VALUES FROM ('${3} 00:00:00+00') TO ('${4} 00:00:00+00')"
    PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d $1 -c "CREATE TABLE IF NOT EXISTS backup.${6}_p${2} PARTITION OF backup.${6} FOR VALUES FROM ('${3} 00:00:00+00') TO ('${4} 00:00:00+00');"
   PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d $1 -c "insert into backup.${6} select * from ${schema_to_be_deleted}.${table_to_be_deleted};"
   PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d $1 -c "drop table ${schema_to_be_deleted}.${table_to_be_deleted};"
}

MoveAggregates() {
    PGHOST='db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com'
    PGUSER='postgres'

    schema_to_be_deleted=$5
    table_to_be_deleted="${6}_p${2}"

    echo "table=${table_to_be_deleted}"

   echo "CREATE TABLE IF NOT EXISTS backup.${6}_p${2} PARTITION OF backup.${6} FOR VALUES FROM ('${3} 00:00:00+00') TO ('${4} 00:00:00+00')"
   
   PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d $1 -c "insert into backup.${6} select * from ${schema_to_be_deleted}.${table_to_be_deleted};"
   PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d $1 -c "drop table ${schema_to_be_deleted}.${table_to_be_deleted};"
}


table_date=$(date -d "-$ndate day" +%Y_%m_%d --date="-183 day")
from_date=$(date -d "-$ndate day" +%Y-%m-%d --date="-183 day")
to_date=$(date -d "-$ndate day" +%Y-%m-%d --date="-182 day")

echo "table_date=${table_date}"
echo "from_date=${from_date}"
echo "to_date=${to_date}"

MoveAggregates $1 ${table_date} ${from_date} ${to_date} "report" "player_aggregates"
MoveAggregates $1 ${table_date} ${from_date} ${to_date} "report" "round_aggregates"
MoveTables $1 ${table_date} ${from_date} ${to_date} "bet" "game_actions"
#MoveTables $1 ${table_date} ${from_date} ${to_date} "bet" "rounds"
