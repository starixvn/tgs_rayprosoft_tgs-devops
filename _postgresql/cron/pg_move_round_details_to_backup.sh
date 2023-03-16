#!/bin/bash
# bash pg_move_tables_to_backup.sh tgsstaging $(date -d "-$ndate day" +%Y_%m_%d --date="-370 day")
# 0 0 * * * root /bin/sh /home/ubuntu/jobs/pg_move_tables_to_backup.sh tgsstaging $(date -d "-$ndate day" +%Y_%m_%d --date="-366 day")

d=2021-05-15
while [ "$d" != 2022-01-01 ]; do
  date_table=$(date +%Y_%m_%d -d "$d + 0 day")
  echo "drop table bet.rounds_p${date_table};"
  d=$(date +%Y-%m-%d -d "$d + 1 day")

  PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -t  << SQL |
	
  SQL
done
