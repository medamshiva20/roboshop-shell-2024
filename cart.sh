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
    echo "INFO: you are root user"
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

VALIDATE $? "Setting Up NPM Source"

yum install nodejs -y &>>$LOG_FILE

VALIDATE $? "Installing NodeJS"

if id "$username" &>/dev/null
then 
    echo "$username already exists."
else
    echo "$username doesn't exists,Let's create"
    useradd $username
fi

if [ -d $directory ]
then 
    echo "$directory already exists"
else
    echo "$directory doesn't exists.Let's create"
    mkdir $directory
fi

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOG_FILE
VALIDATE $? "Download cart artifact"

cd /app &>>$LOG_FILE

VALIDATE $? "Moving into app directory"

unzip /tmp/cart.zip &>>$LOG_FILE

VALIDATE $? "Unzipping artifact"

npm install &>>$LOG_FILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell-2024/cart.service /etc/systemd/system/cart.service

VALIDATE $? "Copying cart service"

systemctl daemon-reload

VALIDATE $? "daemon reloading"

system enable cart.service

VALIDATE $? "Enabling cart service"

systemctl start cart.service

VALIDATE $? "Starting cart service"