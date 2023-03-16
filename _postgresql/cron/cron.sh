SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#30 0 * * * root /bin/sh /home/ubuntu/jobs/JenkinsFullBackup.sh > /dev/null 2>&1
#0 0 * * * root /bin/sh /home/ubuntu/jobs/pg_backup.sh > /dev/null 2>&1
20 21 * * * root /bin/sh /home/ubuntu/pg_logs/download_logs.sh
40 21 * * * root /bin/sh /home/ubuntu/pg_logs-staging/download_logs.sh
0 0 * * * root /bin/sh /home/ubuntu/jobs/pg_cronjob_staging.sh
0 0 * * * root /bin/sh /home/ubuntu/jobs/pg_cronjob.sh
0 0 * * * root /bin/sh /home/ubuntu/jobs/pg_move_tables_to_backup_staging.sh
0 0 * * * root /bin/sh /home/ubuntu/jobs/pg_move_tables_to_backup.sh
0 21 * * * root /bin/sh /home/ubuntu/jobs/vacuum_prod.sh
#0 0 * * * root /bin/sh /home/ubuntu/jobs/pg_move_tables_to_backup_for_rounds.sh tgsstaging
#0 0 * * * root /bin/sh /home/ubuntu/jobs/pg_move_tables_to_backup_for_rounds.sh tgs
0 0 * * * root /bin/sh /home/ubuntu/jobs/delete_ec2_snapshot.sh
