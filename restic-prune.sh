#!/bin/bash

## This script will run the prune command for the configured Repository

# Setting for this script are stored in the settings.sh file
# Do NOT modify this file directly
# configuration is done inside of the settings.sh file

source /home/nick/restic/settings.sh

# Stage 0, Test config

# Ping healthchecks to start the job and record run time
curl -fsS -m 10 --retry 5 "$PRUNE_URL/start"

# Check the output of the cat config command to verify the repository can be opened
CHECK_OUTPUT=$(restic cat config 2>&1)

if [[ $? -eq 0 ]]; then
  echo "repo connect sucessful"
else
  # If unsucessfull, return an error status code and the output to healthchecks
  # Then exit the script
  curl -fsS -m 10 --retry 5 --data-raw "$CHECK_OUTPUT" "$PRUNE_URL/$?"
  exit
fi

# Run forget

OUTPUT=$(echo "Restic Prune Report for "$RESTIC_REPOSITORY && restic forget --keep-last $RESTIC_KEEP_LATEST --keep-daily $RESTIC_KEEP_DAILY \
 --keep-weekly $RESTIC_KEEP_WEEKLY --keep-monthly $RESTIC_KEEP_MONTHLY --keep-yearly $RESTIC_KEEP_YEARLY \
 --prune --max-repack-size 5g)

# Send report to healthchecks
curl -fsS -m 10 --retry 5 --data-raw "$OUTPUT" "$PRUNE_URL/$?"
