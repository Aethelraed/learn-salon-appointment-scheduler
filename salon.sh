#! /bin/bash
#Salon Script
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c "

INSERT_APP(){
  SERVICE_ID=$SERVICE_ID_SELECTED
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE';")
  echo $($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME');")
}

CUSTOMER_BOARD(){
  echo -e "To know our customer we require a Phone Number"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "KYC requires a name"
    read CUSTOMER_NAME
    echo $($PSQL "insert into customers(phone,name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME');")
  fi
  echo -e "The beginning is a delicate time. The end depends on the beginning. Choose yours — wisely."
  read SERVICE_TIME
  C_INSERT=$(INSERT_APP)
  if [[  $C_INSERT == 'INSERT 0 1' ]]
  then
  SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED;")
    echo -e "I have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
} 

SERVICE_LIST(){
  if [[ $1 ]]
  then 
  echo -e "$1"
  fi
  echo -e "\n~~~Services offered~~~\n"
  SERVICES=$($PSQL "select * from services;")
  echo "$SERVICES" | while IFS=" | " read SERVICE_ID SERVICE
  do
    echo "$(echo $SERVICE_ID | sed -E 's/^ +| $//g')) $(echo "$SERVICE" | sed -E 's/^ | $//g')"
  done
  echo -e "\nPlease request your desired service"
  read SERVICE_ID_SELECTED
  S_ID_REQ_RETURN=$($PSQL "select * from services where service_id=$SERVICE_ID_SELECTED");
  if [[ -z $S_ID_REQ_RETURN ]]
  then SERVICE_LIST "\nYour choice did not pass the AML test. Please try again."
  else
    CUSTOMER_BOARD
  fi
}
SERVICE_LIST