#!/bin/bash
# bash pg_move_tables_to_backup.sh tgsstaging $(date -d "-$ndate day" +%Y_%m_%d --date="-370 day")
# 0 0 * * * root /bin/sh /home/ubuntu/jobs/pg_move_tables_to_backup.sh tgsstaging $(date -d "-$ndate day" +%Y_%m_%d --date="-366 day")

PGHOST='db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com'
PGUSER='postgres'
PGPASSWORD='wXfrQBjK4XYFY3KH6D2D'
PGDATABASE='tgs'

d=2021-08-08
while [ "$d" != 2022-02-07 ]; do
  date_table=$(date +%Y_%m_%d -d "$d + 0 day")
  echo "drop table bet.rounds_p${date_table};"
  d=$(date +%Y-%m-%d -d "$d + 1 day")

  PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "drop table bet.rounds_p${date_table};"
  PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "drop table bet.game_actions_p${date_table};"
  PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "drop table report.player_aggregates_p${date_table};"
  PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "drop table report.round_aggregates_p${date_table};"
done
