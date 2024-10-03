#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~"
MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICE_MENU
}

TRIM () {
  echo "$1" | sed -E 's/^ *| *$//g'
}

SERVICE_MENU () {
  #get avaialable services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  #if no services
  if [[ -z $SERVICES ]]
  then
    #send to main menu
    MAIN_MENU "Sorry, no services are available at the moment."
  else
    #display available services
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
    #ask for service selection
    read SERVICE_SELECTION_ID

    #if input is not a number
    if [[ ! $SERVICE_SELECTION_ID =~ ^[0-9]+$ ]]
    then
      #send to main menu
      MAIN_MENU "That is not a valid service number."
    else
      #get selected_service
      SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_SELECTION_ID")
      #if not available
      if [[ -z $SELECTED_SERVICE ]]
      then
        #send to main menu
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        #get customer info
        echo -e "\nWhat's your phone number?"
        read PHONE_NUMBER
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$PHONE_NUMBER'")
        #if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          #get new customer name
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          #insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$PHONE_NUMBER', '$CUSTOMER_NAME')")
        fi
        # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$PHONE_NUMBER'")

        TRIMMED_NAME=$(TRIM "$CUSTOMER_NAME")
        TRIMMED_SERVICE=$(TRIM "$SELECTED_SERVICE")

        echo -e "\nWhat time would you like your $TRIMMED_SERVICE, $TRIMMED_NAME"
        read TIME
        #We don't care about the correct time format
        # insert appointment
        APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_SELECTION_ID, '$TIME')")

        echo "I have put you down for a $TRIMMED_SERVICE at $TIME, $TRIMMED_NAME."
        # send to main menu
        EXIT
      fi
    fi
  fi
}

MAIN_MENU "Welcome to My Salon, how can I help you?\n"