#!/bin/bash

## This script will run the prune command for the configured Repository

# Setting for this script are stored in the settings.sh file
# Do NOT modify this file directly
# configuration is done inside of the settings.sh file

source /home/nick/restic/settings.sh

# Stage 0, Test config

curl -fsS -m 10 --retry 5 "$PRUNE_URL/start"
CHECK_OUTPUT=$(restic cat config 2>&1)

if [[ $? -eq 0 ]]; then
  echo "repo connect sucessful"
else
  curl -fsS -m 10 --retry 5 --data-raw "$CHECK_OUTPUT" "$CHECKIN_URL/$?"
  exit
fi

# Run forget

OUTPUT=$(echo "Restic Prune Report for "$RESTIC_REPOSITORY && restic forget --keep-last $RESTIC_KEEP_LATEST --keep-daily $RESTIC_KEEP_DAILY \
 --keep-weekly $RESTIC_KEEP_WEEKLY --keep-monthly $RESTIC_KEEP_MONTHLY --keep-yearly $RESTIC_KEEP_YEARLY \
 --prune --max-repack-size 5g)
# MESSAGE="Restic Prune Report for "$RESTIC_REPOSITORY$OUTPUT
# Build the JSON to write the message to signal CLI
# JSON_MESSAGE='{"base64_attachments": [], "message": "'$MESSAGE'", "number": "'$SIGNAL_FROM_NUMBER'", "recipients": [ "'$SIGNAL_TO_NUMBER'" ]}'

#This curl command sends a signal message using the Signal-CLI server
# echo $JSON_MESSAGE | curl -X POST -H "Content-Type: application/json" -d @- $SIGNAL_API_URL

curl -fsS -m 10 --retry 5 --data-raw "$OUTPUT" "$PRUNE_URL/$?"
