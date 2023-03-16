#!/bin/bash
psql -d $1 -c "CALL partman.run_maintenance_proc();"
date_logs_to_delete=`date -d "-$ndate day" +%Y_%m_%d --date="-62 day"`
date_to_add=`date -d "-$ndate day" +%Y_%m_%d --date="24 day"`
echo $datestr
echo $PGPASSWORD
echo $PGUSER
echo 'date_to_add=' + $date_to_add
psql -d $1 -c "drop table if exists log.admin_logs_p$date_logs_to_delete;"
psql -d $1 -c "drop table if exists log.api_logs_p$date_logs_to_delete;"
psql -d $1 -c "drop table if exists log.log_records_p$date_logs_to_delete;"

psql -d $1 -c "ALTER TABLE bet.game_actions_p$date_to_add OWNER TO tgs_migration;"
psql -d $1 -c "ALTER TABLE bet.rounds_p$date_to_add OWNER TO tgs_migration;"
psql -d $1 -c "ALTER TABLE log.admin_logs_p$date_to_add OWNER TO tgs_migration;"
psql -d $1 -c "ALTER TABLE log.api_logs_p$date_to_add OWNER TO tgs_migration;"
psql -d $1 -c "ALTER TABLE log.log_records_p$date_to_add OWNER TO tgs_migration;"
psql -d $1 -c "ALTER TABLE report.player_aggregates_p$date_to_add OWNER TO tgs_migration;"
psql -d $1 -c "ALTER TABLE report.round_aggregates_p$date_to_add OWNER TO tgs_migration;"
psql -d $1 -c "VACUUM;"