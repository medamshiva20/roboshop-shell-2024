#!/bin/bash

NAMES=("MongoDB" "Catalogue" "Redis" "User" "Cart" "MySQL" "Shipping" "RabbitMQ" "Payment" "Dispatch" "Web")
INSTANCE_TYPE=""
IMAGE_ID=ami-0b4f379183e5706b9
SECURITY_GROUP_ID=sg-0df20b2370a23626b

for i in ${NAMES[@]}
do
 if [[ $i == "MongoDB" || $i == "MySQL" ]]
 then 
     
    INSTANCE_TYPE="t3.medium"
 else
    INSTANCE_TYPE="t2.micro"
 fi
    echo "creating $i instance"
    aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --count 1 --security-group-ids SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"
done 
