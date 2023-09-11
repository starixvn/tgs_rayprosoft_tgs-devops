#!/bin/bash
# mongodb
# https://docs.aws.amazon.com/documentdb/latest/developerguide/backup_restore-restore_from_snapshot.html
# https://docs.aws.amazon.com/cli/latest/reference/docdb/restore-db-cluster-from-snapshot.html
# https://docs.aws.amazon.com/cli/latest/reference/docdb/describe-db-cluster-snapshots.html

# export docdb_ori_name="tgs-prod"
export docdb_name="tgs-prod-test"
export docdb_backup_name="tgs-game-test"

aws docdb restore-db-cluster-from-snapshot \
    --db-cluster-identifier ${docdb_name} \
    --snapshot-identifier ${docdb_backup_name} \
    --db-subnet-group-name "production subnet group" \
    --region ap-northeast-1 \
    --engine docdb \
    --engine-version 5.0.0 \
    --vpc-security-group-ids sg-001e517212d324c5d 

isdone=0

while [[ isdone == 0 ]] 
do 
    status=$(aws docdb describe-db-clusters \
      --db-cluster-identifier ${docdb_name} \
      --region ap-northeast-1 | jq -r '.DBClusters[0].Status')
      
    if [[ $status == "available" ]]
    then    
        break;
    fi
    echo "$status..."  
    sleep 5
done 
  
aws docdb create-db-instance \
    --db-cluster-identifier ${docdb_name}  \
    --db-instance-identifier ${docdb_name}-1  \
    --promotion-tier 1 \
    --db-instance-class db.t3.medium \
    --region ap-northeast-1 \
    --engine docdb

while [[ isdone == 0 ]] 
do 
    status=$(aws docdb describe-db-instances \
      --db-instance-identifier ${docdb_name}-1 \
      --region ap-northeast-1 | jq -r '.DBInstances[0].DBInstanceStatus')
    
    echo "$status..."    
    
    if [[ $status == "available" ]]
    then    
        break;
    fi
    sleep 5
done 

## the restored time takes about 23 minutes