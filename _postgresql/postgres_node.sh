#!/bin/bash
## https://www.postgresql.org/download/linux/ubuntu/
## https://www.postgresql.org/docs/current/app-pg-dumpall.html

# Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get update

# Install the latest version of PostgreSQL.
# If you want a specific version, use 'postgresql-12' or similar instead of 'postgresql':
sudo apt-get -y install postgresql-14


sudo -u postgres psql
ALTER USER postgres WITH PASSWORD 'abcd1234';  ## 要用原本DB的postgres 的密碼


vi /etc/postgresql/14/main/postgresql.conf  
	# add this line to that file
	listen_addresses = '*'

vi /etc/postgresql/14/main/pg_hba.conf
	# add this line to that file
	host  all  all 0.0.0.0/0 md5
	

sudo /etc/init.d/postgresql restart


### backup
### pg_dumpall  -U postgres -f backup.sql

mkdir /nfsshare_117
chmod -R 777 /nfsshare_117

sudo apt-get install nfs-common -y
mount -t nfs 192.168.50.117:/nfsshare /nfsshare_117
	
### restore     
psql -U postgres -f /nfsshare_117/tgs_full_backup_$(date +"%Y-%m-%d") postgres

psql -U postgres -h 192.168.50.125 -f tgs_full_backup_$(date +"%Y-%m-%d") postgres



################################
## Upgrade Postgresql Version###
################################

pg_lsclusters ## check 
sudo apt-get -y install postgresql-14
sudo pg_dropcluster 14 main --stop
sudo pg_upgradecluster 13 main
pg_lsclusters
  
  
sudo pg_ctlcluster 13 main start


service postgresql restart

## REF: https://www.paulox.net/2022/04/28/upgrading-postgresql-from-version-13-to-14-on-ubuntu-22-04-jammy-jellyfish/


########################
## Remove Postgresql ###
########################


https://ubuntuqa.com/zh-tw/article/1506.html




########################
####  Create User ######
########################

CREATE ROLE tgs_migration WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  CREATEDB
  NOCREATEROLE
  NOREPLICATION
  CONNECTION LIMIT 20
  ENCRYPTED PASSWORD 'md5f240411968bb3ccd0fe8c9dd37b28cb3';
 
CREATE ROLE tgs_app WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION
  CONNECTION LIMIT 400
  ENCRYPTED PASSWORD 'md51fbd050dd88138cd78cb3d8f5a197820';
 
 CREATE ROLE tgs_reader WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION
  CONNECTION LIMIT 10
  ENCRYPTED PASSWORD 'md546f0cbffe0b01c08bcaf389be7eb7c97';
 
  
  
  CREATE ROLE tgspostgressuprtadmin WITH
  LOGIN
  SUPERUSER
  INHERIT
  CREATEDB
  CREATEROLE
  CONNECTION LIMIT 10
  NOREPLICATION
  PASSWORD '0dRCYYSpWSUAFQMcahfnCEfKplsQtpXgal6E';


  ALTER ROLE tgspostgressuprtadmin SET search_path TO "$user", public;
  
  
##################################
######  Backup & Restore #########
##################################

export PGPASSWORD='0dRCYYSpWSUAFQMcahfnCEfKplsQtpXgal6E'
export PGHOST='localhost'
export PGPORT='5432'
export PGUSER='tgspostgressuprtadmin'

export dbname="tgs_2022_11_09"

pg_dump -Fc tgs > ${dbname}.sql 

aws s3 cp ./${dbname}.sql  s3://tgs-dev-backup/postgresql/


aws s3 cp s3://tgs-dev-backup/postgresql/${dbname}.sql ./

pg_restore -d ${dbname} < ${dbname}.sql