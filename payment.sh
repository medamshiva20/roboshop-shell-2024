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

if id "$username" &>/dev/null
then
    echo "$username already exists."
else
    echo "$username doesn't exist,Let's create"
    useradd $username
fi

if [ -d $directory ]
then 
    echo "$directory already exists."
else
    echo "$directory doesn't exists,Let's create"
    mkdir $directory
fi

yum install python36 gcc python3-devel -y &>>$LOGFILE

VALIDATE $? "Installing python"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE

VALIDATE $? "Downloading payment source code"

cd /app &>>$LOGFILE

VALIDATE $? "Moveing into app directory"

unzip -o /tmp/payment.zip &>>$LOGFILE

VALIDATE $? "Unzipping payment"

pip3.6 install -r requirements.txt &>>$LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell-2024/payment.service /etc/systemd/system/payment.service &>>$LOGFILE

VALIDATE $? "Copying payment service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon reload"

systemctl enable payment &>>$LOGFILE

VALIDATE $? "Enabling payment"

systemctl start payment &>>$LOGFILE

VALIDATE $? "Starting payment"

