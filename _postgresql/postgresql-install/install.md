# Ref: https://hackmd.io/Idj8hbZPQhO02SD5iRKHJg

# postgresql installation 
###### tags: `postgresql`


https://www.postgresql.org/download/linux/ubuntu/

# Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get update

# Install the latest version of PostgreSQL.
# If you want a specific version, use 'postgresql-12' or similar instead of 'postgresql':
sudo apt-get -y install postgresql


sudo -u postgres psql
ALTER USER postgres WITH PASSWORD 'postgres';


vi /etc/postgresql/14/main/postgresql.conf  
	# add this line to that file
	listen_addresses = '*'

vi /etc/postgresql/14/main/pg_hba.conf
	# add this line to that file
	host  all  all 0.0.0.0/0 md5
	

sudo /etc/init.d/postgresql restart


 ### backup
 pg_dumpall  -U postgres -f backup.sql

### restore     
psql -f tgs.sql postgres

https://www.postgresql.org/docs/current/app-pg-dumpall.html
  
  
  