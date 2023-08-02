#!/bin/bash
apt update
apt upgrade
apt install unzip -y
apt install jq -y
apt install postgresql-client-14
(
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
)