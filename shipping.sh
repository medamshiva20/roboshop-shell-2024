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

yum install maven -y &>>$LOG_FILE

VALIDATE $? "Installing maven package"

if id "$username" &>/dev/null
then 
    echo "$username already exists."
else
    echo "$username doesn't exists,Let's create"
    useradd $username
fi

if [ -d $directory ]
then
    echo "$directory already exists."
else
    echo "$directory doesn't exists,Let's create"
    mkdir $directory

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOG_FILE

VALIDATE $? "Downloading shipping artifact"

cd /app &>>$LOG_FILE

VALIDATE $? "Moving into app directory"

unzip /tmp/shipping.zip &>>$LOG_FILE

VALIDATE $? "Unzipping shipping"

mvn clean package &>>$LOG_FILE

VALIDATE $? "Build and package"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE

VALIDATE $? "Renaming shipping.jar file"

cp /home/centos/roboshop-shell-2024/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE

VALIDATE $? "copying shipping service"

systemctl daemon-reload &>>$LOG_FILE

VALIDATE $? "daemon reload"

systemctl enable shipping.service &>>$LOG_FILE

VALIDATE $? "Enabling shipping service"

systemctl start shipping.service &>>$LOG_FILE

VALIDATE $? "Starting shipping service"

yum install mysql -y &>>$LOG_FILE

VALIDATE $? "Installing mysql"

mysql -h mysql.sivadevops.website -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$LOG_FILE

VALIDATE $? "Loading schema into mysql"

systemctl restart shipping.service &>>$LOG_FILE

VALIDATE $? "Restart shipping"