#!/bin/ash
DATE=`date +%Y%m%d`
export AWS_ACCESS_KEY_ID=${RCLONE_CONFIG_BACKUP_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${RCLONE_CONFIG_BACKUP_SECRET_ACCESS_KEY}
for BUCKET in `aws s3api list-buckets | jq '.Buckets[].Name' | tr -d \" | grep -e '-backup$'`; do
    echo "Creating snapshot of ${BUCKET} to ${BUCKET}-snapshots/${DATE}/"
    /usr/bin/rclone sync BACKUP:${BUCKET} BACKUP:${BUCKET}-snapshots/${DATE}/ -v --ignore-checksum
    echo "Updating ${BUCKET}-snapshots bucket's lifecycle configuration"
    aws s3api put-bucket-lifecycle-configuration --bucket ${BUCKET}-snapshots --lifecycle-configuration file:///s3-lifecycle.json
done