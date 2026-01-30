#!/bin/bash
set -e
USERID=$(id -u)

LOGS_FOLDER="/var/log/shellscript"
LOGS_FILE="$LOGS_FOLDER/$0.log"

if [ $USERID -ne 0 ]; then
    echo "run this as root user" | tee -a $LOGS_FILE
    exit 1
fi
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo "$2  is failure" | tee -a $LOGS_FILE
    else
        echo "$2  is success" | tee -a $LOGS_FILE
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo repo..."

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "installing monogdb server..."

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enable monogdb s..."

systemctl start mongod &>>$LOGS_FILE
VALIDATE $? "start monogdb ..."

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "allowing remote connection ..."

systemctl restart mongod &>>$LOGS_FILE
VALIDATE $? "restarted mongod ..."
