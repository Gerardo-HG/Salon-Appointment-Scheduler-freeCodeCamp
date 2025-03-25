#!/bin/bash  

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"  

# Function to show the list of services  
show_services() {  
  echo "$($PSQL 'SELECT service_id, name FROM services ORDER BY service_id')" | while IFS='|' read SERVICE_ID NAME; do  
    echo "$SERVICE_ID) $NAME"  
  done  
}  

# Bienvenida  
echo -e "\nWelcome to My Salon, how can I help you?\n"  

# Show services initially  
show_services  

while true; do  
  # Solicitar una elección  
  echo -e "\nChoose a service (enter the number):"  
  read SERVICE_ID_SELECTED  

  # Verificar si el servicio existe  
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")  

  if [[ -z $SERVICE_NAME ]]; then  
    echo -e "\nI could not find that service. What would you like today?"  
    # Show the services again  
    show_services  
  else  
    # Solicitar el número de teléfono del cliente  
    echo -e "\nWhat's your phone number?"  
    read CUSTOMER_PHONE  
    
    # Buscar el cliente por teléfono  
    CUSTOMER_RECORD=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")  

    if [[ -z $CUSTOMER_RECORD ]]; then  
       echo -e "\nI don't have a record for that phone number, what's your name?"   
       read CUSTOMER_NAME  

       echo -e "\nWhat time would you like your appointment?"  
       read SERVICE_TIME  
    
      # Insertar el nuevo cliente  
      $PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"  

      # Obtener el ID del cliente  
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")  

      # Insertar la cita  
      $PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"  

      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."  
    else  
      # Si el cliente ya existe, obtener su nombre  
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")  

      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"  
      read SERVICE_TIME  

      # Obtener el ID del cliente existente      
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")  

      # Insertar la cita para el cliente existente  
      $PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"  

      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."  
    fi  

    break # Exit the loop if the selection is valid  
  fi  
done  