#!/bin/bash
for filename in $(aws rds describe-db-log-files --db-instance-identifier db-staging | jq -r '.DescribeDBLogFiles[] | .LogFileName')
do
	aws rds download-db-log-file-portion --db-instance-identifier db-staging --output text --no-paginate --log-file $filename  >> /home/ubuntu/pg_logs-staging/$filename
done

sudo find  /home/ubuntu/pg_logs-staging/error/postgresql.log.* -type f -mtime +14 -exec rm -rf {} \;

sudo pgbadger /home/ubuntu/pg_logs-staging/error/*  -o /var/www/html/pgbadger-staging/log.html -f stderr

