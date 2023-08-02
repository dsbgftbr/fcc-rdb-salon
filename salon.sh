#!/bin/bash
# Make salon appointments

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~ Welcome to the salon~~\n"

SELECT_SERVICE() {

  # print argument if passed
  if [[ -n $1 ]]
  then
    echo $1
  fi

  # Get services
  SERVICES_RESULT=$($PSQL " SELECT service_id, name, price FROM services ORDER BY service_id ")

  # Show a numbered list of services
  echo -e "\nChoose a service:"
  echo "$SERVICES_RESULT" | while IFS="|" read SERVICE_ID NAME PRICE
  do
    echo "$SERVICE_ID) $NAME ... $PRICE"
  done

  # Ask service id
  read SERVICE_ID_SELECTED

  # Get matched service
  SELECTED_SERVICE_CHOICE=$(echo "$SERVICES_RESULT" | grep "^$SERVICE_ID_SELECTED|")

  # If not a valid number
  if [[ -z $SELECTED_SERVICE_CHOICE ]]
  then
    # Show services again
    SELECT_SERVICE "Please enter a valid number."
  
  else
    # Get service name
    SERVICE_NAME=$(echo $SELECTED_SERVICE_CHOICE | sed 's/^[0-9]+\|//; s/\|[0-9.]+//' -E)
    
  fi

}

# Ask for service
SELECT_SERVICE

# Ask for customer phone
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Get customer id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE' ")

# If new customer
if [[ -z $CUSTOMER_ID ]]

then
  # Ask for customer name
  echo -e "\nWhat's your name?"
  read CUSTOMER_NAME
  
  # Add new customer
  ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME') ")

  # Get new customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE' ")

else
  # Get customer name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")

fi

# Ask for appointment time
echo -e "\nWhat time do you want to set?"
read SERVICE_TIME

# Create appointment
APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ( $CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME') ")

# If successful
if [[ $APPOINTMENT_RESULT == "INSERT 0 1" ]]
then
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
else
  echo "\nSorry. We cannot set your appointment."
fi
