#!/bin/bash
# mongodb
# https://docs.aws.amazon.com/cli/latest/reference/docdb/describe-db-cluster-snapshots.html
export docdb_name="tgs-prod-test"
export rds_db_name="db-prod-test"
export redis_name="redis-test"

## delete
aws elasticache delete-cache-cluster \
    --cache-cluster-id ${redis_name}

aws docdb delete-db-instance \
    --region ap-northeast-1 \
    --db-instance-identifier ${docdb_name}-1

aws docdb delete-db-cluster \
    --db-cluster-identifier ${docdb_name} \
    --region ap-northeast-1 \
    --skip-final-snapshot

aws rds delete-db-instance \
    --db-instance-identifier ${rds_db_name} \
    --skip-final-snapshot

