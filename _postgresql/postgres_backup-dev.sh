#!/bin/bash
export PGPASSWORD='abcd1234'
export PGHOST='192.168.50.125'
export PGPORT='5432'
export PGUSER='rpdev'
POSTGRES_BACKUP_HOME=/var/lib/postgres_backup
POSTGRES_BACKUP_FILE=tgs_full_backup_$(date +"%Y-%m-%d")
POSTGRES_BACKUP_FILE_TO_DELETE=tgs_full_backup_$(date -d "7 days ago" +"%Y-%m-%d")


#pg_dump -w tgs  -f $POSTGRES_BACKUP_HOME/$POSTGRES_BACKUP_FILE
pg_dumpall -f $POSTGRES_BACKUP_HOME/$POSTGRES_BACKUP_FILE

find /var/lib/postgres_backup/tgs_full_backup_* -type f -mtime +6 -exec rm -rf {} \;

date_logs_to_delete=`date -d "-$ndate day" +%Y-%m-%d --date="-15 day"`


psql -d tgs -c "delete from log.api_logs where recorded_on <= '$date_logs_to_delete';"
psql -d tgs -c "delete from log.admin_logs where recorded_on <= '$date_logs_to_delete';"
psql -d tgs -c "delete from log.log_records where recorded_on <= '$date_logs_to_delete';"
psql -d tgs -c "VACUUM;"

aws s3 rm  s3://tgs-dev-backup/postgresql/$JENKINS_BACKUP_FILE_TO_DELETE
aws s3 cp $POSTGRES_BACKUP_HOME/$POSTGRES_BACKUP_FILE s3://tgs-dev-backup/postgresql/


aws s3 cp ./tgs_2022_11_09.sql  s3://tgs-dev-backup/postgresql/


export PGPASSWORD='abcd1234'
export PGHOST='localhost'
export PGPORT='5432'
export PGUSER='postgres'
