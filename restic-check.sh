#!/bin/bash

# This is a script to automate restic backup verification

# Setting for this script are stored in the settings.sh file
# Do NOT modify this file directly
# configuration is done inside of the settings.sh file

source /home/nick/restic/settings.sh

# Stage 0, Test config

# Ping healthchecks to start the job and record run time
curl -fsS -m 10 --retry 5 "$CHECK_VERIFY_URL/start"

# Check the output of the cat config command to verify the repository can be opened
CHECK_OUTPUT=$(restic cat config 2>&1)

if [[ $? -eq 0 ]]; then
  echo "repo connect sucessful"
else
  # If unsucessfull, return an error status code and the output to healthchecks
  # Then exit the script
  curl -fsS -m 10 --retry 5 --data-raw "$CHECK_OUTPUT" "$CHECK_VERIFY_URL/$?"
  exit
fi

# Stage 1, Run backup
echo "Verifying backups of "$RESTIC_REPOSITORY

# Save the output of the backup command into the output variable to send to healthchecks
OUTPUT=$(echo "Restic Check Report for "$RESTIC_REPOSITORY && restic check --read-data-subset $RESTIC_VERIFY_PERCENT 2>&1)

# Stage 2 send the report to healthchecks
curl -fsS -m 10 --retry 5 --data-raw "$OUTPUT" "$CHECK_VERIFY_URL/$?"
