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

yum install python36 gcc python3-devel -y &>>$LOG_FILE

VALIDATE $? "Installing python"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOG_FILE

VALIDATE $? "Downloading payment source code"

cd /app &>>$LOG_FILE

VALIDATE $? "Moveing into app directory"

unzip -o /tmp/payment.zip

VALIDATE $? "Unzipping payment"

pip3.6 install -r requirements.txt


