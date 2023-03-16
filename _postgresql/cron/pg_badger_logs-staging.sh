#!/bin/bash
## REF: https://github.com/darold/pgbadger
db="db-staging"
logpath="/home/ubuntu/pg_logs-staging"
webpath="/var/www/html/pgbadger-staging/"

for filename in $(aws rds describe-db-log-files --db-instance-identifier $db | jq -r '.DescribeDBLogFiles[] | .LogFileName')
do
    echo "filename=$filename" |& tee -a $logpath/log-$(date +'%Y-%m-%d-%H').txt
    sudo rm -rf $filename
    aws rds download-db-log-file-portion --db-instance-identifier $db --output text --no-paginate --log-file $filename  >> $logpath/$filename
done

sudo find  $logpath/error/postgresql.log.* -type f -mtime +30 -exec rm -rf {} \;

sudo rm -rf  /tmp/pgbadger.pid

sudo pgbadger -I -v $logpath/error/postgresql.log.$(date -d "1 hour ago"  +'%Y-%m-%d-%H') \
        -O $webpath -f stderr |& tee -a $logpath/log-$(date +'%Y-%m-%d-%H').txt

sudo pgbadger -I -v $logpath/error/postgresql.log.$(date -d +'%Y-%m-%d-%H') \
        -O $webpath -f stderr |& tee -a $logpath/log-$(date +'%Y-%m-%d-%H').txt


sudo find  $logpath/log-* -type f -mtime +3 -exec rm -rf {} \;
sudo find  $logpath/error/log-* -type f -mtime +3 -exec rm -rf {} \;
