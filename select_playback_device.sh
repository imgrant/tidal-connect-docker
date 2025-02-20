#!/bin/sh

CONFIG_FILE=./Docker/CONFIG

ARRAY_DEVICES=()
DEVICES=$(docker exec -ti tidal_connect /app/ifi-tidal-release/bin/ifi-pa-devs-get 2>/dev/null | grep device#)

echo ""
echo "Found output devices..."
echo ""
#make newlines the only separator
IFS=$'\n'
re_parse="^device#([0-9])+=(.*)$"
for line in $DEVICES
do
  if [[ $line =~ $re_parse ]]
  then
    device_num="${BASH_REMATCH[1]}"
    device_name="${BASH_REMATCH[2]}"
    
    echo "${device_num}=${device_name}"
    ARRAY_DEVICES+=( ${device_name} )
  fi
done

while :; do
    read -ep 'Choose your output Device (0-9): ' number
    [[ $number =~ ^[[:digit:]]+$ ]] || continue
    (( ( (number=(10#$number)) <= 9999 ) && number >= 0 )) || continue
    # Here I'm sure that number is a valid number in the range 0..9999
    # So let's break the infinite loop!
    break
done

export PLAYBACK_DEVICE="${ARRAY_DEVICES[$number]}"
echo ""
echo "Playback device is set to: ${PLAYBACK_DEVICE}"

CONFIG_FILE=./CONFIG
if test -f "$CONFIG_FILE"; then
  sed -i -e "s/^PLAYBACK_DEVICE.*$/PLAYBACK_DEVICE\=${PLAYBACK_DEVICE}/g" Docker/.env
  echo "Updated config file..."
  echo ""
  echo "Please restart TIDAL Service for changes to take effect."
fi

