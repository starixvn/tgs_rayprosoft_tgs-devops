#!/bin/sh
### Restore

aws s3 cp s3://tgs-dev-backup/jenkins/jenkins-backup.$(date +'%Y-%m-%d').tar.gz jenkins.tar.gz
sudo tar zxvf ./jenkins.tar.gz -C /var/lib/jenkins

service jenkins restart