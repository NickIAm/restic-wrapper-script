#!/bin/bash

# Copy this file to settings.sh and change that copy

# Repository parameters
export RESTIC_PASSWORD=""
export RESTIC_REPOSITORY=""
export RESTIC_READ_CONCURRENCY=2

# example aws configuration
# export AWS_SECRET_ACCESS_KEY=
# export AWS_ACCESS_KEY_ID=
# export RESTIC_REPOSITORY=s3:gateway.storjshare.io/restic/production

# Backup options
export RESTIC_PACK_SIZE=64
export EXCLUDE_FILE=/home/user/.restic_exclude
export BACKUP_SOURCE=/home/nick/restic/backup_include

# Check Options
export RESTIC_VERIFY_PERCENT=0.1%

# Forget Options
export RESTIC_KEEP_LATEST=5
export RESTIC_KEEP_DAILY=5
export RESTIC_KEEP_WEEKLY=6
export RESTIC_KEEP_MONTHLY=1
export RESTIC_KEEP_YEARLY=1

# Prune options
export RESTIC_MAX_PRUNE_REPACK_SIZE=25g

# Options for Healthchecks.io monitoring
export CHECKIN_URL=""
export PRUNE_URL=""
export CHECK_VERIFY_URL=""

# Static Variables, don't change
RESTIC_HOSTNAME=$(hostname)
