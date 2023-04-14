#!/bin/sh
###
# Easy Jenkins backup script
#
# Save script and named JenkinsFullBackup.sh
# chmod +x JenkinsFullBackup.sh
#

# Which path of your jenkins install
JENKINS_HOME=/var/lib/jenkins

# Whcih path of your backup file saved
JENKINS_BACKUP_HOME=/var/lib/jenkins_backup

# Jenkins backup file ex: jenkins-backup.2014-10-05.tar.gz
JENKINS_BACKUP_FILE=jenkins-backup.$(date +"%Y-%m-%d").tar.gz
JENKINS_BACKUP_FILE_TO_DELETE=jenkins-backup.$(date -d "7 days ago" +"%Y-%m-%d").tar.gz

cd $JENKINS_HOME

# backup workspace need lot of diskspace, you can ignore like
# --exclude=./workspace
tar zcvf $JENKINS_BACKUP_HOME/$JENKINS_BACKUP_FILE \
        --exclude="./caches" \
        --exclude="./jobs/*/branches" \
        --exclude="./jobs/*/builds" \
        --exclude="./workspace" \
        ./*

#find $JENKINS_BACKUP_HOME/*.tar.gz -type f -mtime +1 -exec rm -rf {} \;
aws s3 rm  s3://tgs-dev-backup/jenkins/$JENKINS_BACKUP_FILE_TO_DELETE
aws s3 cp $JENKINS_BACKUP_HOME/$JENKINS_BACKUP_FILE s3://tgs-dev-backup/jenkins/