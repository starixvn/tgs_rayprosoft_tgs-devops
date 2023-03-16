#!/bin/bash
## REF: https://github.com/darold/pgbadger

db="db-production"
logpath="/home/ubuntu/pg_logs"
webpath="/var/www/html/pgbadger/"


for filename in $(aws rds describe-db-log-files --db-instance-identifier db-production | jq -r '.DescribeDBLogFiles[] | .LogFileName')
do
	aws rds download-db-log-file-portion --db-instance-identifier db-production --output text --no-paginate --log-file $filename  >> /home/ubuntu/pg_logs/$filename
done

sudo find  /home/ubuntu/pg_logs/error/postgresql.log.* -type f -mtime +0 -exec rm -rf {} \;





aws rds download-db-log-file-portion --db-instance-identifier db-production --output text --no-paginate --log-file error/postgresql.log.2022-11-24-05  >> /home/ubuntu/pg_logs/error/postgresql.log.2022-11-24-05

aws rds download-db-log-file-portion --db-instance-identifier db-production --log-file error/postgresql.log.2022-11-24-05  >> /home/ubuntu/pg_logs/error/postgresql.log.2022-11-24-05



## Initial, 產生 log.html for all

sudo pgbadger /home/ubuntu/pg_logs/error/*  -o /var/www/html/pgbadger/log.html -f stderr

sudo pgbadger /home/ubuntu/pg_logs-staging/error/*  -o /var/www/html/pgbadger-staging/log.html -f stderr

sudo pgbadger -b "$(date -d "31 days ago"  +'%Y-%m-%d') 00:00:00" /home/ubuntu/pg_logs/error/*  -o /var/www/html/pgbadger/log.html -f stderr

sudo pgbadger -b "$(date -d "31 days ago"  +'%Y-%m-%d') 00:00:00" /home/ubuntu/pg_logs-staging/error/*  -o /var/www/html/pgbadger-staging/log.html -f stderr

## Incremetal, 產生 index.html day by day

sudo pgbadger --retention 30 -I -v /home/ubuntu/pg_logs/error/* \
	-O /var/www/html/pgbadger/ -f stderr |& tee -a /home/ubuntu/pg_logs/log-$(date +'%Y-%m-%d-%H').txt

sudo pgbadger --retention 30 -I -v /home/ubuntu/pg_logs-staging/error/* \
	-O /var/www/html/pgbadger-staging/ -f stderr |& tee -a /home/ubuntu/pg_logs/log-$(date +'%Y-%m-%d-%H').txt


sudo pgbadger --retention 30 -I -v /home/ubuntu/pg_logs-staging/error/postgresql.log.$(date -d "1 days ago"  +'%Y-%m-%d')-* -O /var/www/html/pgbadger-staging/ -f stderr

sudo pgbadger -I -v /home/ubuntu/pg_logs-staging/error/postgresql.log.$(date -d "1 days ago"  +'%Y-%m-%d')-* -O /var/www/html/pgbadger-staging/ -f stderr

sudo pgbadger -I -v /home/ubuntu/pg_logs/error/postgresql.log.$(date -d "1 days ago"  +'%Y-%m-%d')-* -O /var/www/html/pgbadger/ -f stderr

sudo pgbadger -I -v /home/ubuntu/pg_logs/error/postgresql.log.$(date -d +'%Y-%m-%d')-* -O -H /var/www/html/pgbadger/ -f stderr



db="db-stagint"
logpath="/home/ubuntu/pg_logs-staging"
webpath="/var/www/html/pgbadger-staging/"


sudo pgbadger -I -v /home/ubuntu/pg_logs-staging/error/postgresql.log.$(date -d "1 hour ago"  +'%Y-%m-%d')-* \
        -O /var/www/html/pgbadger-staging/ -f stderr |& tee -a /home/ubuntu/pg_logs-staging/log-$(date +'%Y-%m-%d-%H')-test1.txt


sudo pgbadger -I -v /home/ubuntu/pg_logs/error/postgresql.log.$(date -d "1 hour ago"  +'%Y-%m-%d')-* \
        -O /var/www/html/pgbadger/ -f stderr |& tee -a /home/ubuntu/pg_logs/log-$(date +'%Y-%m-%d-%H')-test1.txt
		

sudo pgbadger -I -v /home/ubuntu/pg_logs-staging/error/postgresql.log.$(date +'%Y-%m-%d')-* -O -H /var/www/html/pgbadger-staging/ -f stderr



sudo pgbadger -I -v /home/ubuntu/pg_logs/error/postgresql.log.2022-11-24-* -O /var/www/html/pgbadger/ --day-report 2022-11-24

sudo pgbadger -I -X -v /home/ubuntu/pg_logs/error/postgresql.log.* -O /var/www/html/pgbadger/ -f stderr

sudo pgbadger -I -X -v /home/ubuntu/pg_logs-staging/error/postgresql.log.* -O /var/www/html/pgbadger-staging/ -f stderr





## 下面的指令會讓www 的檔案變成 Initial 的情況

sudo pgbadger -X -I -O /var/www/html/pgbadger/ --rebuildls