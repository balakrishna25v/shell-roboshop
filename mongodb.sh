#!/bin/bash
USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m" # Red color
G="\e[32m" # Green color
Y="\e[33m" # Yellow color
N="\e[0m"  # No color

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script  root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

# Create logs directory if it doesn't exist
mkdir -p $LOGS_FOLDER

VALIDATE()
{ 
    if [ $1 -ne 0 ]; then
        echo "$2 ....failed" | tee -a $LOGS_FILE
        exit 1
    else
        echo "$2 ....success" | tee -a $LOGS_FILE
    fi
}

cp mongodb.repo /etc/yum.repos.d/mongodb.repo &>> $LOGS_FILE
VALIDATE $? "copying mongodb repo file"

dnf install mongodb-org -y &>> $LOGS_FILE
VALIDATE $? "installing mongodb"

systemctl enable mongod &>> $LOGS_FILE
VALIDATE $? "enabling mongodb"

systemctl start mongod &>> $LOGS_FILE
VALIDATE $? "starting mongodb" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "allowing remote access to mongodb"

systemctl restart mongod &>> $LOGS_FILE
VALIDATE $? "restarting mongodb"