#!/bin/bash
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