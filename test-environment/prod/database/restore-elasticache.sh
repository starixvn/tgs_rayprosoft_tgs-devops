#!/bin/bash
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
  --security-group-ids sg-02bbd834258ab9840 \
  --snapshot-arns arn:aws:s3:::tgs-db-backup/redis-0001.rdb
  
## the restored time takes about 12 minutes