#!/Bin/bash 

USERID=$(id -u)
LOGSDIR=/tmp
DATE=$(date)
SCRIPT_NAME=$0
LOG_FILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\[33m"

VALIDATE(){
if [ $1 -ne 0 ]
then 
    echo -e "$2...$R FAILURE $N"
    exit 1
else
    echo -e "$2...$G SUCCESS $N"
fi
}

if [ $USERID -ne 0 ]
then 
    echo -e "$R ERROR:: Please run this script with root user $N"
    exit 1
else
    echo "INFO: You are root user"
fi


curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$LOG_FILE

VALIDATE $? "Configuring Yum repo from script provided by the vendor"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$LOG_FILE

VALIDATE $? "Configuring Yum repos from RabbitMQ"

yum install rabbitmq-server -y &>>$LOG_FILE

VALIDATE $? "Install rabbitmq"

systemctl enable rabbitmq-server &>>$LOG_FILE

VALIDATE $? "Enabling rabbitmq"

systemctl start rabbitmq-server &>>$LOG_FILE

VALIDATE $? "Starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE

VALIDATE $? "Creating roboshop user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE

VALIDATE $? "Add permissions for roboshop user"
