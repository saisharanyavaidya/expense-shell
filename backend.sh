#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
echo "pls enter DB password"
read -s mysql_root_password

VALIDATE (){
    if [ $1 -ne 0 ]
    then echo -e "$2 $R failed $N ..."
    exit 1
    else echo -e "$2 $G success $N ..."
    fi
}

if [ $USERID -ne 0 ]
then echo "not super user"
exit 1
else 
echo "you are super user"
fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "enabling nodejs"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then useradd expense &>>$LOGFILE
VALIDATE $? "user addition"
else echo "user already there"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "making directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading backend code" 

cd /app 

rm -rf /app/* 
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "unzip backend" 

npm install &>>$LOGFILE
VALIDATE $? "installing npm"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "copying backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon-reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "start backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "enable backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "installing mysql"

mysql -h db.avyan.site -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "restart backend"