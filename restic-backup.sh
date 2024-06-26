#!/bin/bash

# This is a script to automate restic backups

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
echo "Taking backups to "$RESTIC_REPOSITORY

# Loop through a list of given directories to backup
# Caputre the output of the backup command and loop inside the output variable
# and ship it off to signal cli for notification

OUTPUT=$(for dir in "${BACKUP_DIRECTORIES[@]}" ; do
  if [ -d "$dir" ]; then

    echo "\n"
    echo "Backing up '$dir' \n"
#     OUTPUT=$(restic backup --exclude-file=/home/nick/.restic_exclude \
#     --exclude-caches $dir 2>&1 | )
    restic backup --exclude-file=$EXCLUDE_FILE --exclude-caches $dir | awk '{printf "%s\\n", $0}'

  else
    echo  "Directory '$dir' doesn't exsist \n"
  fi

done
)
# Stage 2 parse and send the report

# Build the message to send the status report
# REPORT=$(echo $OUTPUT | jq .message_type)

# Build the message
MESSAGE="Restic Backup Report\n"$RESTIC_HOSTNAME"\n"$OUTPUT

# Build the JSON to write the message to signal CLI
JSON_MESSAGE='{"base64_attachments": [], "message": "'$MESSAGE'", "number": "'$SIGNAL_FROM_NUMBER'", "recipients": [ "'$SIGNAL_TO_NUMBER'" ]}'

#   #This curl command sends a signal message using the Signal-CLI server
echo $JSON_MESSAGE | curl -X POST -H "Content-Type: application/json" -d @- $SIGNAL_API_URL
# fi
