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

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "enabling nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/*

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading front end project"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip 

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "copying front end service"

systemctl restart nginx
VALIDATE $? "re starting nginx"