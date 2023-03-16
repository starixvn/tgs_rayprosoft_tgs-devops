#!/bin/bash
for i in $(seq 0 1 23)
do
   printf -v i "%02d" $i ; echo $i
   sudo rm -rf  /tmp/pgbadger.pid
   sudo pgbadger -I -v /home/ubuntu/pg_logs/error/postgresql.log.2023-02-01-$i \
        -O /var/www/html/pgbadger/ -f stderr |& tee -a /home/ubuntu/pg_logs/log-2023-02-01-$i.txt
done
