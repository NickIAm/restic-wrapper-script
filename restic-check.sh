#!/bin/bash

# This is a script to automate restic backup verification

# Setting for this script are stored in the settings.sh file
# Do NOT modify this file directly
# configuration is done inside of the settings.sh file

source settings.sh

# Stage 0, Test config

curl -fsS -m 10 --retry 5 "$CHECKIN_URL/start"
CHECK_OUTPUT=$(restic cat config 2>&1)

if [[ $? -eq 0 ]]; then
  echo "repo connect sucessful"
else
  curl -fsS -m 10 --retry 5 --data-raw "$CHECK_OUTPUT" "$CHECKIN_URL/$?"
  exit
fi

# Stage 1, Run backup
echo "Verifying backups of "$RESTIC_REPOSITORY

# Tag with testing while script is in testing
# Save the output of the backup command into the output variable in json format for later parsing
OUTPUT=$(echo "" && restic check --read-data-subset $RESTIC_VERIFY_PERCENT 2>&1)

# Stage 2 parse and send the report

# Build the message to send the status report
# REPORT=$(echo $OUTPUT | jq .message_type)

# Build the message
MESSAGE="Restic Check Report for "$RESTIC_REPOSITORY$OUTPUT

# Build the JSON to write the message to signal CLI
# JSON_MESSAGE='{"base64_attachments": [], "message": "'$MESSAGE'", "number": "'$SIGNAL_FROM_NUMBER'", "recipients": [ "'$SIGNAL_TO_NUMBER'" ]}'

#   #This curl command sends a signal message using the Signal-CLI server
# echo $JSON_MESSAGE | curl -X POST -H "Content-Type: application/json" -d @- $SIGNAL_API_URL

curl -fsS -m 10 --retry 5 --data-raw "$MESSAGE" "$CHECK_VERIFY_URL/$?"
