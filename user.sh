#!/bin/bash

USERID=$(id -u)
LOGDIR=/tmp
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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOG_FILE

VALIDATE $? "Setting Up NPM Source" &>>$LOG_FILE

yum install nodejs -y &>>$LOG_FILE

VALIDATE $? "Installing NodeJS"

if id "$username" &>/dev/null
then
    echo "$username already exists."
else
    echo "$username doesn't exists,Let's create the user"
    useradd $username
fi

if [ -d $directory ]
then 
    echo "$directory already exists"
else
    echo "$directory doesn't exists,Let's create"
    mkdir $directory
fi

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOG_FILE

VALIDATE $? "Download the user arifact"

cd /app &>>$LOG_FILE

VALIDATE $? "Moving into app directory"

unzip /tmp/user.zip &>>$LOG_FILE

VALIDATE $? "Unzipping user artifact"

npm install &>>$LOG_FILE

VALIDATE $? "Install Dependencies"

cp /home/centos/roboshop-shell-2024/user.service /etc/systemd/system/user.service &>>$LOG_FILE

VALIDATE $? "Copying user service"

systemctl daemon-reload &>>$LOG_FILE

VALIDATE $? "Reload daemon"

systemctl enable user.service &>>$LOG_FILE

VALIDATE $? "Enabling user service"

systemctl start user.service &>>$LOG_FILE

VALIDATE $? "Starting user service"

cp /home/centos/roboshop-shell-2024/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE

VALIDATE $? "Copying mongodb repo"

yum install mongodb-org-shell -y &>>$LOG_FILE

VALIDATE $? "Installing mongodb client package"

mongo --host mongodb.sivadevops.website < /app/schema/user.js &>>$LOG_FILE

VALIDATE $? "Loading schema into mongodb"

systemctl restart user.service &>>$LOG_FILE

VALIDATE $? "Restarting user service"
