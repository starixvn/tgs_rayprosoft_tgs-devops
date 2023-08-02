# vi /etc/crontab
0 0 * * * root /bin/bash /root/jobs/pg_detach_attach_round_partition-staging.sh
1 0 * * * root /bin/bash /root/jobs/pg_detach_attach_round_partition-prod.sh
0 1 * * * root /bin/bash /root/jobs/delete_ec2_snapshot.sh
0 2 * * * root /bin/bash /root/jobs/delete_s3_before_30_days.sh
# sudo service cron reload