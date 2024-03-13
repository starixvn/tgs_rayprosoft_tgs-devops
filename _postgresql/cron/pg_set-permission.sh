#!/bin/bash
export env=$1
export table=$2

if [[ $env == "staging" ]]; then

export PGHOST='db-staging.cglu874fh5rb.ap-east-1.rds.amazonaws.com'
export PGUSER='tgsstagingsuprtadmin'
export PGPASSWORD='U:BZYD^b]B!Au*j&\8;sf\/4*_3Z;yq`'
export PGDATABASE='tgsstaging'

elif [[ $env == "prod" ]]; then  

export PGHOST='db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com'
export PGUSER='tgspostgressuprtadmin'
export PGPASSWORD='0dRCYYSpWSUAFQMcahfnCEfKplsQtpXgal6E'
export PGDATABASE='tgs'

fi

echo "PGHOST=${PGHOST}"
echo "PGUSER=${PGUSER}"
echo "PGDATABASE=${PGDATABASE}"
echo "table=$table"

psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "grant all privileges on $table to tgs_migration;"
psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "grant all privileges on $table to tgs_app;"
psql -h ${PGHOST} -U ${PGUSER} -d ${PGDATABASE} -c "grant select on $table to tgs_reader;"