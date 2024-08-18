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

yum module disable mysql -y &>>$LOG_FILE

VALIDATE $? "Disabling MySQL"

cp /home/centos/roboshop-shell-2024/mysql.repo /etc/yum.repos.d/mysql.repo &>>$LOG_FILE

VALIDATE $? "Copying MySQL repo into yum.repos.d" 

yum install mysql-community-server -y &>>$LOG_FILE

VALIDATE $? "Installing MySQL"

systemctl enable mysqld &>>$LOG_FILE

VALIDATE $? "Enabling MySQL service"

systemctl start mysqld &>>$LOG_FILE

VALIDATE $? "Starting Mysqld service"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE

VALIDATE $? "Setting up root password"