#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m" # Red color
G="\e[32m" # Green color
Y="\e[33m" # Yellow color
N="\e[0m"  # No color
SCRIPT_DIR=$PWD
MONGODB_HOST="mongodb.baludevops.online" # replace with your MongoDB hostname   

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
    echo -e "Roboshop user already exists...$Y Skipping user creation $N" | tee -a $LOGS_FILE
fi

mkdir -p /app 
VALIDATE $? "creating application directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOGS_FILE
VALIDATE $? "downloading application code"


cd /app 
VALIDATE $? "movingto  directory to app"

rm -rf * &>>$LOGS_FILE
VALIDATE $? "cleaning old application code"

unzip /tmp/catalogue.zip &>>$LOGS_FILE
VALIDATE $? "unzipping application code"

npm install &>>$LOGS_FILE
VALIDATE $? "installing npm dependencies"  

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGS_FILE
VALIDATE $? "copying systemd service file"

systemctl daemon-reload &>>$LOGS_FILE
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "starting and enabling catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
dnf install mongodb-org-shell -y &>>$LOGS_FILE

INDEX=$(mongosh --host $MONGODB_HOST --eval 'db.getMongo().getDBNames().indexOf("catalogue")' -q --quiet)

if [ "$INDEX" -eq -1 ]; then
mongosh --host $MONGODB_HOST </app/db/catalogue.js &>>$LOGS_FILE

VALIDATE $? "loading data into MongoDB"
else
    echo -e "Catalogue database already loaded...$Y Skipping data loading $N" | tee -a $LOGS_FILE
fi

systemctl restart catalogue
VALIDATE $? "restarting catalogue"
