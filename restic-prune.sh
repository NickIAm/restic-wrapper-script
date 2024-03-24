#!/bin/bash

## This script will run the prune command for the configured Repository

# Setting for this script are stored in the settings.sh file
# Do NOT modify this file directly
# configuration is done inside of the settings.sh file

source settings.sh

# Static Variables, don't change
RESTIC_HOSTNAME=$(hostname)

# Stage 0, Test config
restic cat config > /dev/null 2> /dev/null

if [[ $? -eq 0 ]]; then
  echo "repo connect sucessful"
else
  curl -fsS -m 10 --retry 5 --data-raw "Could not connect to the restic repo" "$CHECKIN_URL/fail"

fi
# Run forget

OUTPUT=$(echo "" && restic forget --keep-last $RESTIC_KEEP_LATEST --keep-daily $RESTIC_KEEP_DAILY \
 --keep-weekly $RESTIC_KEEP_WEEKLY --keep-monthly $RESTIC_KEEP_MONTHLY --keep-yearly $RESTIC_KEEP_YEARLY \
 --prune --max-repack-size 5g)
MESSAGE="Restic Prune Report for "$RESTIC_REPOSITORY$OUTPUT
# Build the JSON to write the message to signal CLI
# JSON_MESSAGE='{"base64_attachments": [], "message": "'$MESSAGE'", "number": "'$SIGNAL_FROM_NUMBER'", "recipients": [ "'$SIGNAL_TO_NUMBER'" ]}'

#This curl command sends a signal message using the Signal-CLI server
# echo $JSON_MESSAGE | curl -X POST -H "Content-Type: application/json" -d @- $SIGNAL_API_URL

curl -fsS -m 10 --retry 5 --data-raw "$MESSAGE" $CHECKIN_URL
