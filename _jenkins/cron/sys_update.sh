#!/bin/bash
apt update
apt upgrade -y
docker system prune -f
systemctl restart jenkins
rm -rf /var/lib/jenkins/workspace/*@tmp
rm -rf /var/lib/jenkins/workspace/*@libs
rm -rf /var/lib/jenkins/workspace/*@2