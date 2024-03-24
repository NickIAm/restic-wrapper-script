# Welcome to the restic backup scripts
This repository contains a set of backup scripts to help automate restic.

Each script has a built in webhook call to signal-cli to report back the results of each command.
This is useful to help monitor the backups and ensure they are running correctly.
This could in theory be adapted to also call a webhook for notification to other platforms like slack, etc...

There are 3 scripts, each one does a different part of the backup process.
restic-backup.sh runs the backup as configured inside the settings.sh file.
restic-prune.sh handles pruning and the forget command. Using forget will help to reduce
the backup size by remove unneeded old snapshots.
restic-check.sh optionally checks the repository integrity by verifying everything is correct.
It can also read a portion of the data as a random percentage to help detect corruption.

## Usage
Each script should be run with cron or another scheduler like systemd to run at your needed interval.
[cronguru](https://crontab.guru) can be used to help set the cron expression.
This guide assumes you have signal-cli already running and configured.

My crontab currently looks like this:
```
0 2 * * 1 /home/user/restic/restic-prune.sh
0 1 * * * /home/user/restic/restic-backup.sh
0 3 * * 1 /home/user/restic/restic-check.sh
```

## Configuration
These scripts assume you already have a repository initialised.
If you don't please see the restic documentation on how to do this.

The repository location and password are defined in the settings.sh file.
This file must exist or the scripts won't work.
Create a copy of the example settings file and rename it to `settings.sh` .
These are simply a list of the environment variables used by restic to define
the repository location, the password, what gets backed up, etc...
Signal-CLI also has some options that need to be set, such as the phone numbers
and url of the server.
