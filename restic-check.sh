#!/bin/bash

# This is a script to automate restic backup verification

# Setting for this script are stored in the settings.sh file
# Do NOT modify this file directly
# configuration is done inside of the settings.sh file

source settings.sh

# Stage 0, Test config
restic cat config > /dev/null

if [[ $? -eq 0 ]]; then
  echo "repo connect sucessful"
fi

# Stage 1, Run backup
echo "Verifying backups of "$RESTIC_REPOSITORY

# Tag with testing while script is in testing
# Save the output of the backup command into the output variable in json format for later parsing
OUTPUT=$(restic check --read-data-subset $RESTIC_VERIFY_PERCENT 2>&1 | awk '{printf "%s\\n", $0}')

# Stage 2 parse and send the report

# Build the message to send the status report
# REPORT=$(echo $OUTPUT | jq .message_type)

# Build the message
MESSAGE="Restic Check Report\n"$RESTIC_HOSTNAME"\n"$OUTPUT

# Build the JSON to write the message to signal CLI
JSON_MESSAGE='{"base64_attachments": [], "message": "'$MESSAGE'", "number": "'$SIGNAL_FROM_NUMBER'", "recipients": [ "'$SIGNAL_TO_NUMBER'" ]}'

#   #This curl command sends a signal message using the Signal-CLI server
echo $JSON_MESSAGE | curl -X POST -H "Content-Type: application/json" -d @- $SIGNAL_API_URL
# fi
