#!/bin/bash 

USERID=$(id -u)
LOGSDIR=/tmp
SCRIPT_NAME=$0
DATE=$(date +%F)
LOG_FILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log
username=roboshop
directory=/app

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2... $R FAILURE $N"
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then 
    echo "ERROR:: Please run this script with root user"
else
    echo "INFO: You are root user"
fi

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOG_FILE
``
VALIDATE $? "Setting Up NPM Source"

yum install nodejs -y &>>$LOG_FILE

VALIDATE $? "Installing NodeJS"

#once the user is created, if you run this script 2nd time
# this command will defnitely fail
# IMPROVEMENT: first check the user already exist or not, if not exist then create

if id "$username" &> /dev/null
then
   echo "$username already exists."
else
    echo "$username doesn't exist. Creating user"
    useradd $username &>>$LOG_FILE
fi

if [ -d $directory ]
then
    echo "$directory already exist"
else
    echo "$directory doesn't exist,Let's create it"
    mkdir $directory
fi

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOG_FILE

VALIDATE $? "Download the catalogue artifact"

cd /app &>>$LOG_FILE

VALIDATE $? "Move into app directory"

unzip -o /tmp/catalogue.zip &>>$LOG_FILE

VALIDATE $? "Unzipping catalogue"

npm install &>>$LOG_FILE

VALIDATE $? "Install dependencies"

cp /home/centos/roboshop-shell-2024/catalogue.service /etc/systemd/system/catalogue.service &>>$LOG_FILE

VALIDATE $? "Copying catalogue service"

systemctl daemon-reload &>>$LOG_FILE

VALIDATE $? "Daemon reload"

systemctl enable catalogue.service &>>$LOG_FILE

VALIDATE $? "Enabling catalogue"

systemctl start catalogue.service &>>$LOG_FILE

VALIDATE $? "Starting catalogue"

cp /home/centos/roboshop-shell-2024/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE

VALIDATE $? "Copying Mongodb repo into yum.repos.d"

yum install mongodb-org-shell -y &>>$LOG_FILE

VALIDATE $? "Installing mongodb client package"

mongo --host mongodb.sivadevops.website < /app/schema/catalogue.js &>>$LOG_FILE

VALIDATE $? "Load schema into mongodb"

systemctl restart catalogue.service &>>$LOG_FILE

VALIDATE $? "Restarting catalogue service"

