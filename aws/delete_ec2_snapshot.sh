#!/bin/bash
datesToDelete=$(date -d '3 days ago' +"%Y-%m-%d")
echo $datesToDelete
snapshots_to_delete=$(aws ec2 describe-snapshots --owner-ids 060812454361 --query "Snapshots[?StartTime<='$datesToDelete'].SnapshotId" --output text)

for snap in $snapshots_to_delete; do
  echo $snap
  aws ec2 delete-snapshot --snapshot-id $snap
done