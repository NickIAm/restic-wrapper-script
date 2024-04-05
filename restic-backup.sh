#!/bin/bash

# This is a script to automate restic backups

# Setting for this script are stored in the settings.sh file
# Do NOT modify this file directly
# configuration is done inside of the settings.sh file

source /home/nick/restic/settings.sh

# Stage 0, Test config

# Ping healthchecks to start the job and record run time
curl -fsS -m 10 --retry 5 "$CHECKIN_URL/start"

CHECK_OUTPUT=$(restic cat config 2>&1)

if [[ $? -eq 0 ]]; then
  echo "repo connect sucessful"
else
  # If unsucessfull, return an error status code and the output to healthchecks
  # Then exit the script
  curl -fsS -m 10 --retry 5 --data-raw "$CHECK_OUTPUT" "$CHECKIN_URL/$?"
  exit
fi

# Stage 1, Run backup
echo "Taking backups to "$RESTIC_REPOSITORY

# Loop through a list of given directories to backup
# Caputre the output of the backup command and loop inside the output variable
# and ship it off to signal cli for notification
# Store the exit code of the last run, check it is non zero and continue

OUTPUT=$(for dir in "${BACKUP_DIRECTORIES[@]}" ; do
  if [ -d "$dir" ]; then

    echo "Backing up '$dir'"
    restic backup --retry-lock 1h --exclude-file=$EXCLUDE_FILE --exclude-caches $dir 2>&1
    EXIT_CODE=$?
    echo ""

    if [[ $EXIT_CODE -ne 0 ]]; then
      echo "The previous backup run had an error"
      exit $EXIT_CODE
    fi

  else
    echo  "Directory '$dir' doesn't exsist"
  fi
done
)

# Stage 2 send the report
curl -fsS -m 10 --retry 5 --data-raw "$OUTPUT" "$CHECKIN_URL/$?"
