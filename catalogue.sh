#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
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

VALIDATE(){ 
    if [ $1 -ne 0 ]; then
        echo -e "$2 ....$R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ....$G SUCCESS$N" | tee -a $LOGS_FILE
    fi

}

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disabling Nodejs Default version"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Enabling Nodejs 20 version"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Installing Nodejs"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
      useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
      VALIDATE $? "creating system user"
else
    echo "roboshop user already exists. Skipping user creation." | tee -a $LOGS_FILE
fi

mkdir -p /app 
VALIDATE $? "creating application directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOGS_FILE
VaLIDATE $? "downloading application code"