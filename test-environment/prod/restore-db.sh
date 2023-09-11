#!/bin/bash
# rds
# https://docs.aws.amazon.com/cli/latest/reference/rds/restore-db-instance-to-point-in-time.html
# https://docs.aws.amazon.com/cli/latest/reference/rds/delete-db-instance.html
export db_name="db-prod-test"

aws rds restore-db-instance-to-point-in-time \
    --source-db-instance-identifier db-production \
    --target-db-instance ${db_name} \
    --restore-time 2023-09-11T00:00:00.000Z \
    --db-instance-class db.t3.medium \
    --db-subnet-group-name "default-vpc-0b86a361eb192585e" \
    --vpc-security-group-ids "sg-05d5fe9b1ad228e89"

# redis
# https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/Clusters.Create.html#Clusters.Create.API
# https://docs.aws.amazon.com/cli/latest/reference/elasticache/
export redis_name="redis-test"

aws elasticache create-cache-cluster \
  --cache-cluster-id ${redis_name} \
  --cache-node-type cache.t3.medium \
  --engine redis \
  --num-cache-nodes 1 \
  --cache-parameter-group default.redis7 \
  --cache-subnet-group-name tgs-redis \
  --snapshot-arns arn:aws:s3:::tgs-db-backup/redis-0001.rdb
    
# mongodb
# https://docs.aws.amazon.com/documentdb/latest/developerguide/backup_restore-restore_from_snapshot.html
# https://docs.aws.amazon.com/cli/latest/reference/docdb/restore-db-cluster-from-snapshot.html
# https://docs.aws.amazon.com/cli/latest/reference/docdb/describe-db-cluster-snapshots.html

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