#!/bin/bash
# bash pg_move_tables_to_backup.sh tgsstaging $(date -d "-$ndate day" +%Y_%m_%d --date="-370 day")
# 0 0 * * * root /bin/sh /home/ubuntu/jobs/pg_move_tables_to_backup.sh tgsstaging $(date -d "-$ndate day" +%Y_%m_%d --date="-366 day")

PGHOST='db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com'
PGUSER='postgres'
PGPASSWORD='wXfrQBjK4XYFY3KH6D2D'
PGDATABASE='tgsstaging'

d=2021-08-08
while [ "$d" != 2022-02-07 ]; do
  date_from=${d}
  date_to=$(date +%Y-%m-%d -d "$d + 1 day")
  date_table=$(date +%Y_%m_%d -d "$d + 0 day")
  echo "CREATE TABLE IF NOT EXISTS backup.rounds_p${date_table} PARTITION OF backup.rounds FOR VALUES FROM ('${date_from} 00:00:00+00') TO ('{$date_to} 00:00:00+00');"
  d=$(date +%Y-%m-%d -d "$d + 1 day")

  PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "CREATE TABLE IF NOT EXISTS backup.rounds_p${date_table} PARTITION OF backup.rounds FOR VALUES FROM ('${date_from} 00:00:00+00') TO ('{$date_to} 00:00:00+00');"
  PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "CREATE TABLE IF NOT EXISTS backup.game_actions_p${date_table} PARTITION OF backup.game_actions FOR VALUES FROM ('${date_from} 00:00:00+00') TO ('{$date_to} 00:00:00+00');"
  PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "CREATE TABLE IF NOT EXISTS backup.player_aggregates_p${date_table} PARTITION OF backup.player_aggregates FOR VALUES FROM ('${date_from} 00:00:00+00') TO ('{$date_to} 00:00:00+00');"
  PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "CREATE TABLE IF NOT EXISTS backup.round_aggregates_p${date_table} PARTITION OF backup.round_aggregates FOR VALUES FROM ('${date_from} 00:00:00+00') TO ('{$date_to} 00:00:00+00');"
done
