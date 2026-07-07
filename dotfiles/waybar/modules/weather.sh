#!/bin/bash

# Get weather data from wttr.in
LOCATION="Skopje"  # Change this to your location
WEATHER_DATA=$(curl -s "wttr.in/${LOCATION}?format=%C+%t")

if [ -z "$WEATHER_DATA" ]; then
    echo '{"text": "N/A", "tooltip": "Weather data unavailable"}'
    exit 0
fi

# Extract temperature and condition
TEMP=$(echo "$WEATHER_DATA" | grep -oP '\+?\-?\d+°C' | head -1)
CONDITION=$(echo "$WEATHER_DATA" | sed "s/${TEMP}//g" | xargs)

# Output JSON
echo "{\"text\": \"${TEMP}\", \"tooltip\": \"${CONDITION} ${TEMP}\"}"
