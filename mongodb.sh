#!/bin/bash

USERID=$(id -u)
DATE=$(date +%F)
LOGSDIR=/tmp
SCRIPT_NAME=$0
LOG_FILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ]
then 
    echo -e "ERROR:: Please run this script with root user"
    exit 1
else
    echo "INFO: You are root user"
fi

VALIDATE(){

    if [ $1 -ne 0 ]
    then 
        echo -e "$2 ...$R FAILURE $N"
        exit 1
    else
        echo -e "$2 ...$G SUCCESS $N"
    fi
}
cp mongo.repo /etc/yum.repos.d/ &>>$LOG_FILE

VALIDATE $? "Copied mongo.repo into yum.repos.d"

yum install mongodb-org -y  &>>$LOG_FILE

VALIDATE $? "Installing MongoDB"

systemctl enable mongod  &>>$LOG_FILE

VALIDATE $? "Enabling Mongod service"

systemctl start mongod  &>>$LOG_FILE

VALIDATE $? "Starting Mongod Service"

sed -i "s/127.0.0.1/0.0.0.0/" /etc/mongod.conf  &>>$LOG_FILE

VALIDATE $? "Enabling mongodb to the other servers or internet"

systemctl restart mongod  &>>$LOG_FILE

VALIDATE $? "Restarting Mongod"