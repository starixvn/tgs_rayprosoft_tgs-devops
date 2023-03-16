#!/bin/bash
db="db-staging"
logpath="/home/ubuntu/pg_logs-staging"
webpath="/var/www/html/pgbadger-staging/"
filename=error/postgresql.log.$(date +'%Y-%m-%d-%H' -d '-60 minutes')
aws rds download-db-log-file-portion --db-instance-identifier $db --output text --starting-token 0 --log-file $filename  >> $logpath/$filename
sudo rm -rf  /tmp/pgbadger.pid
sudo pgbadger -I -v $logpath/$filename -O $webpath -f stderr
rm -rf $logpath/$filename
