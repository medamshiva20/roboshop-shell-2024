#!/bin/bash 

USERID=$(id -u)
LOGSDIR=/tmp
SCRIPT_NAME=$0
DATE=$(date)
LOG_FILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log
username=roboshop
directory=/app

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ]
then 
    echo -e "$R ERROR:: Please run this script with root user $N"
    exit 1
else
    echo "INFO: You are root user"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

yum install nginx -y &>>$LOG_FILE

VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOG_FILE

VALIDATE $? "Enabling nginx service"

systemctl start nginx &>>$LOG_FILE

VALIDATE $? "Starting nginx service"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE

VALIDATE $? "remove default content from this folder"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$LOG_FILE

VALIDATE $? "Downloading frontend application code"

cd /usr/share/nginx/html &>>$LOG_FILE

VALIDATE $? "Moving into the nginx default folder"

unzip /tmp/web.zip &>>$LOG_FILE

VALIDATE $? "Unzipping artifact"

cp /home/centos/roboshop-shell-2024/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE

VALIDATE $? "Copying roboshop.conf file"

systemctl restart nginx &>>$LOG_FILE

VALIDATE $? "Restarting nginx service"

