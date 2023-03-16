#!/bin/bash
# bash pg_move_tables_to_backup.sh tgsstaging $(date -d "-$ndate day" +%Y_%m_%d --date="-370 day")
# 0 0 * * * root /bin/sh /home/ubuntu/jobs/pg_move_tables_to_backup.sh tgsstaging $(date -d "-$ndate day" +%Y_%m_%d --date="-366 day")

MoveData() {
    PGHOST='db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com'
    PGUSER='postgres'
   #PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d $1 -c "insert into backup.$2_bak select * from backup.$2 where $6 >= '$3' and $6 < '$4';"

   d=$3
   while [ "$d" != $4 ]; do
          date_table=$(date +%Y_%m_%d -d "$d + 0 day")
          echo "${date_table};"
          d=$(date +%Y-%m-%d -d "$d + 1 day")
          PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "drop table backup.$2_p${date_table};"
   done

   PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d $1 -c "CREATE TABLE IF NOT EXISTS backup.${2}_p${5} PARTITION OF backup.${2} FOR VALUES FROM ('${3} 00:00:00+00') TO ('${4} 00:00:00+00');"
   PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d $1 -c "insert into backup.${2} select * from backup.$2_bak;"
  #PGPASSWORD='wXfrQBjK4XYFY3KH6D2D' psql -h ${PGHOST} -U ${PGUSER} -d $1 -c "delete from backup.$2_bak;"
}



PGHOST='db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com'
PGUSER='postgres'
PGPASSWORD='wXfrQBjK4XYFY3KH6D2D'
PGDATABASE='tgsstaging'

StartDate=$(date -d '200 days ago' +"%Y-%m-01")
EndDate=$(date -d '180 days ago' +"%Y-%m-01")
KeyMonth=$(date -d '200 days ago' +"%Y_%m")

MoveData 'tgsstaging' 'player_aggregates' $StartDate $EndDate $KeyMonth "created_on"
MoveData 'tgsstaging' 'round_aggregates' $StartDate $EndDate $KeyMonth "created_on"
MoveData 'tgsstaging' 'rounds' $StartDate $EndDate $KeyMonth  "created_on"
MoveData 'tgsstaging' 'game_actions' $StartDate $EndDate $KeyMonth "recorded_on"