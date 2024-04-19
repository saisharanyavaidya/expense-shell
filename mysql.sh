#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
echo "pls enter DB password"
read -s mysql-root-password

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

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "installing mysql"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "enable mysql"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "start mysql"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#VALIDATE $? "setting up root password"

mysql -h DB.avyan.site -uroot -p${mysql-root-password} -e 'show databases;' &>>$LOGFILE

if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ${mysql-root-password}
    VALIDATE $? "isetting up root password"
else
    echo "my sql root password already set"
fi




