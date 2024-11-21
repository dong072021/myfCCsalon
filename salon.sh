#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Welcome message
echo -e '\n~~~~~ MY SALON ~~~~~\n'

# Function to display the services
DISPLAY_SERVICES() {
  echo -e "\nHere are the services we offer:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  
  # Loop through the services and display them in numbered format
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Main menu function
MAIN_MENU() {
  DISPLAY_SERVICES
  
  # Prompt user to select a service
  echo -e "\nWhat would you like today? (Please enter the service number)"
  read SERVICE_ID_SELECTED
  
  # Validate the service_id
  SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  
  if [[ -z $SERVICE_EXISTS ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # Get customer's phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    
    # Check if the phone number exists in the customers table
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    
    # If the customer doesn't exist, prompt for name and insert into customers table
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      
      # Insert new customer into the customers table
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    
    # Get customer_id from customers table
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    
    # Get the service_name for confirmation message
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
    
    # Ask for the appointment time
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    
    # Insert the appointment into the appointments table
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    # Confirmation message
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    
    # End the script
    exit
  fi
}

# Start the script by calling the MAIN_MENU
MAIN_MENU
