#!/bin/bash 

USERID=$(id -u)
LOGSDIR=/tmp
SCRIPT_NAME=$0
DATE=$(date)
LOGFILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ]
then
    echo -e "$R ERRROR:: Please run this script with root user $N"
    exit 1
else
    echo "INFO: You are root user"
fi

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOG_FILE

VALIDATE $? "Configire Redis Repo"

yum module enable redis:remi-6.2 -y &>>$LOG_FILE

VALIDATE $? "Enable redis repo"

yum install redis -y &>>$LOG_FILE

VALIDATE $? "Installing Redis"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis.conf &>>$LOG_FILE

VALIDATE $? "Enabling redis to the other servers to connect"

systemctl restart redis &>>$LOG_FILE

VALIDATE $? "Restarting redis"


