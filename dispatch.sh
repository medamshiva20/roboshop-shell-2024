#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
username=roboshop
directory=/app

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

yum install golang -y &>>$LOGFILE

VALIDATE $? "Installing golang"

if id "$username" &>/dev/null
then
    echo "$username already exists"
else
    echo "$username doesn't exists,Let's create"
    useradd $username
fi

if [ -d $directory ]
then 
    echo "$directory already exists"
else
    echo "$directory doesn't exists,Let's create"
    mkdir $directory
fi

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>>$LOGFILE

VALIDATE $? "Download dispatch source code"

cd /app  &>>$LOGFILE

VALIDATE $? "Moving into app directory"

unzip -o /tmp/dispatch.zip &>>$LOGFILE

VALIDATE $? "Unzipping dispatch source code"

go mod init dispatch &>>$LOGFILE

VALIDATE $? "Install dependencies"

go get &>>$LOGFILE

VALIDATE $? "Go get"

go build &>>$LOGFILE

VALIDATE $? "Build package"

cp /home/centos/roboshop-shell-2024/dispatch.service /etc/systemd/system/dispatch.service &>>$LOGFILE

VALIDATE $? "Copying dispatch service"

systemctl daemon-reload

VALIDATE $? "daemon reload"

systemctl enable dispatch 

VALIDATE $? "Enabling dispatch service"

systemctl start dispatch

VALIDATE $? "Starting dispatch service"
