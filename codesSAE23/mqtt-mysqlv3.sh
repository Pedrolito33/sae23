#!/bin/bash
# MQTT Configuration
MQTT_BROKER="mqtt.iut-blagnac.fr"
MQTT_TOPIC="AM107/by-room/+/data"

# MySQL Configuration
MYSQL_HOST="localhost"
MYSQL_USER="noah"
MYSQL_PASSWORD="rt"
MYSQL_DATABASE="sae23"

# Path to MySQL executable in XAMPP
MYSQL_BIN="/opt/lampp/bin/mysql"  # Change this path if necessary

# Mapping of building letters to IDs
declare -A batiment_ids
batiment_ids=( ["A"]=1 ["B"]=2 ["C"]=3 ["E"]=4 )

# Listen for MQTT messages and process each message
mosquitto_sub -h "$MQTT_BROKER" -t "$MQTT_TOPIC" | while read -r message
do
    # Print the raw message for debugging
    echo "Received message: $message"

   # Extract necessary fields from JSON message using jq
   room=$(echo "$message" | jq -r '.[1].room')
   building=$(echo "$message" | jq -r '.[1].Building')
   device_name=$(echo "$message" | jq -r '.[1].deviceName')
   temperature=$(echo "$message" | jq -r '.[0].temperature')

   # Print extracted values for debugging
   echo "Extracted room: $room"
   echo "Extracted building: $building"
   echo "Extracted device_name: $device_name"
   echo "Extracted temperature: $temperature"
  
   id_bat="${batiment_ids[$building]}"

   # Insert the manager if not already present
   query_gestion="INSERT IGNORE INTO Gestionnaire (id_gestion,mdp) VALUES ('$id_bat','bat$building');"
   echo "Executing query: $query_gestion"
   "$MYSQL_BIN" -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -D "$MYSQL_DATABASE" -e "$query_gestion"
				
	# Insert the building if not already present
   query_batiment="INSERT IGNORE INTO Batiment (id_bat,nom_bat,gestion) VALUES ('$id_bat','$building','$id_bat');"
   echo "Executing query: $query_batiment"
   "$MYSQL_BIN" -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -D "$MYSQL_DATABASE" -e "$query_batiment"	
				
	# Insert the room if not already present
	query_salle="INSERT IGNORE INTO Salle (nom_salle,batiment) VALUES ('$room','$id_bat')"
	echo "Executing query: $query_salle"
	"$MYSQL_BIN" -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -D "$MYSQL_DATABASE" -e "$query_salle"
			
	# Insert the captors if not already present
	query_capteur="INSERT IGNORE INTO Capteur (nom_capteur,type_capteur,unite,salle) VALUES ('$device_name','temperature','°C','$room')"
	echo "Executing query: $query_capteur"
    "$MYSQL_BIN" -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -D "$MYSQL_DATABASE" -e "$query_capteur"

	# Insert the mesures if not already present
	query_mesure="INSERT IGNORE INTO Mesure (date_mesure,valeur,capteur) VALUES (NOW(),'$temperature','$device_name')"
	echo "Executing query: $query_capteur"
    "$MYSQL_BIN" -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -D "$MYSQL_DATABASE" -e "$query_mesure"
done
