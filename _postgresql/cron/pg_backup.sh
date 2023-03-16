#!/bin/bash
pg_dump -w tgs  -f aws_tgs_full_backup_$(date +"%Y-%m-%d")

find aws_tgs_full_backup_* -type f -mtime +1 -exec rm -rf {} \;

# echo "0 0 * * * postgres /bin/sh /var/lib/postgresql/backup.sh > /dev/null 2>&1" >> /etc/crontab
