#!/bin/bash

# This is a script to automate restic backups

# Setting for this script are stored in the settings.sh file
# Do NOT modify this file directly
# configuration is done inside of the settings.sh file

source /home/nick/restic/settings.sh

# Stage 0, Test config

# Ping healthchecks to start the job and record run time
curl -fsS -m 10 --retry 5 "$CHECKIN_URL/start"
echo ""

CHECK_OUTPUT=$(restic cat config 2>&1)

if [[ $? -eq 0 ]]; then
  echo "Repo connected sucessfully"
else
  # If unsucessfull, return an error status code and the output to healthchecks
  # Then exit the script
  curl -fsS -m 10 --retry 5 --data-raw "$CHECK_OUTPUT" "$CHECKIN_URL/$?"
  exit
fi

# Stage 1, Run backup
echo "Taking backups to "$RESTIC_REPOSITORY

# Use a list of given directories to backup
# Capture the output of the backup command inside the output variable
# and ship it off to healthcheck server for notification and logging
# Store the exit code of the last run, check it is non zero and continue

OUTPUT=$(echo "Backing up the following directories"
    cat $BACKUP_SOURCE
    restic backup --retry-lock 1h --one-file-system --tag v2_script --files-from=$BACKUP_SOURCE --exclude-file=$EXCLUDE_FILE --exclude-caches 2>&1
    EXIT_CODE=$?
    echo ""

    if [[ $EXIT_CODE -ne 0 ]]; then

#     An exit code of 3 means some files were inaccessable during the snapshot

      if [[ $EXIT_CODE -eq 3 ]]; then

        echo "The previous backup run could not access certain files"
        exit 0
      fi
      exit $EXIT_CODE
    fi
)

# Stage 2 send the report
curl -fsS -m 10 --retry 5 --data-raw "$OUTPUT" "$CHECKIN_URL/$?"
echo ""
