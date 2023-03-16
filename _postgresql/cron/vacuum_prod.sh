#!/bin/bash
# https://developer.aliyun.com/article/43412
tables=$(psql -U postgres -d $db -c "select schemaname || '.' || tablename as tablename from pg_tables where schemaname in ('dbo','bet','report') order by schemaname, tablename;" |grep -v "tablename")

for table in $tables
do
        if [[ "$table" == *"("* ]] || [[ "$table" == *")"* ]]  ; then
           continue;
        fi

        echo "vacuum verbose analyze $table;"
        psql -U postgres -d $db -c "vacuum analyze $table;"
        echo "table $table has finished vacuum"
done


sudo pgbadger --retention 30 -I -v /home/ubuntu/pg_logs-staging/error/postgresql.log.$(date -d "2 days ago"  +'%Y-%m-%d')-* -O /var/www/html/pgbadger-staging/ -f stderr

sudo pgbadger --retention 30 -I -v /home/ubuntu/pg_logs/error/postgresql.log.$(date -d "1 days ago"  +'%Y-%m-%d')-* -O /var/www/html/pgbadger/ -f stderr

