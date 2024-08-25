#!/bin/bash

NAMES=$@
INSTANCE_TYPE=""
IMAGE_ID=ami-0b4f379183e5706b9
SECURITY_GROUP_ID=sg-0df20b2370a23626b
DOMAIN_NAME=sivadevops.website
HOSTED_ZONE_ID=Z10006173JK368096M6NX

for i in $@
do
  if [[ $i == "mongodb" || $i == "mysql" ]]
  then
    INSTANCE_TYPE="t3.medium"
  else
    INSTANCE_TYPE=t2.micro
  fi
  echo $i creating 
  IPADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE  --security-group-ids $ECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"|jq -r '.Instances[0].PrivateIpAddress')
  echo $i created: $IPADDRESS
   aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch 
   '
   {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": "'$i.$DOMAIN_NAME'",
                            "Type": "A",
                            "TTL": 300,
                            "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                        }}]
    }
    '
done
