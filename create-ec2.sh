#!/bin/bash

NAMES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "web")
INSTANCE_TYPE=""
IMAGE_ID=ami-0b4f379183e5706b9
SECURITY_GROUP_ID=sg-0df20b2370a23626b
DOMAIN_NAME=sivadevops.website


# if mysql or mongodb instance_type should be t3.medium , for all others it is t2.micro
for i in "${NAMES[@]}"
do  
    #INSTANCE_NAME=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=mongodb,redis,mysql,rabbitmq,catalogue,user,cart,shipping,payment,web)
    #echo "Instance $INSTANCE_NAME" already exists
    if [[ $i == "mongodb" || $i == "mysql" ]]
    then
        INSTANCE_TYPE="t3.medium"
    else
        INSTANCE_TYPE="t2.micro"
    fi
    echo "creating $i instance"
    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE  --security-group-ids $ECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "created $i instance: $IP_ADDRESS"
    aws route53 change-resource-record-sets --hosted-zone-id Z10006173JK368096M6NX --change-batch '
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
# imporvement
# check instance is already created or not
# update route53 record
done