#!/bin/ash
DATE=`date +%Y%m%d`
export AWS_ACCESS_KEY_ID=${RCLONE_CONFIG_ORIGIN_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${RCLONE_CONFIG_ORIGIN_SECRET_ACCESS_KEY}
for BUCKET in `aws s3api list-buckets | jq '.Buckets[].Name' | tr -d \"`; do
    echo "${BUCKET}: "
    AWS_ACCESS_KEY_ID=${RCLONE_CONFIG_ORIGIN_ACCESS_KEY_ID}
    AWS_SECRET_ACCESS_KEY=${RCLONE_CONFIG_ORIGIN_SECRET_ACCESS_KEY}
    tags=$(aws s3api get-bucket-tagging --bucket ${BUCKET} 2&>/dev/null | jq -c '.[][] | {(.Key): .Value}' | tr '\n' '\t' | grep Backup)
    if [[ $? -eq 0 ]]; then
        echo $tags
        /usr/bin/rclone copy ORIGIN:${BUCKET} BACKUP:${BUCKET}-backup -v --ignore-checksum
        /usr/bin/rclone copy BACKUP:${BUCKET}-backup BACKUP:${BUCKET}-backup-snapshots/${DATE}/ -v --ignore-checksum
        AWS_ACCESS_KEY_ID=${RCLONE_CONFIG_BACKUP_ACCESS_KEY_ID}
        AWS_SECRET_ACCESS_KEY=${RCLONE_CONFIG_BACKUP_SECRET_ACCESS_KEY}
        aws s3api put-bucket-lifecycle-configuration --bucket ${BUCKET}-backup-snapshots --lifecycle-configuration file:///s3-lifecycle.json
    fi
done