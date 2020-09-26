#!/bin/bash
. lib.sh
#################################################################
# Methods imported from lib:
# MsgType()
# LoadConfiguration(config)
# ValidateBackupSource(source)
# ValidateBackupDestination(destination)
# ValidateBackupParent(parent,destination)
# SetConfigField(path,field,value)
# FullBackup(source,destination,filename,config)
# IncrementalBackup(source,destination,filename,snapshot,parent)
# PerformBackup(source,destination,backupfile,snapshotfile)
#################################################################
MsgType "Welcome to incremental backups tool."

read -r -d '' welcome_print << EOM
Usage:
 *backup-full: Perform full backup of the folder.
 *backup-increment: Perform incremental backup.
 *restore: Restore folder to state from given time [date]
  -example:  restore '2020/01/11 09:35:00'
 *show: show files in backup files  [date]
  -example:  show '2020/01/11 09:35:00'
 *list: list all backup files

EOM
echo  "$welcome_print"

MYDIR="$(dirname "$(readlink -f "$0")")"
CONFIG_FILE="$MYDIR/configuration.conf"
LoadConfiguration $CONFIG_FILE
##################################################
# Fields loaded from the configuration.conf file:
# BACKUP_SOURCE
# BACKUP_DESTINATION
# BACKUP_PARENT
# BACKUP_FILENAME
##################################################

ValidateBackupSource $BACKUP_SOURCE
ValidateBackupDestination $BACKUP_DESTINATION

ACTION="$1"
ARGUMENT="$2"
case "$ACTION" in
  backup-full)
    FullBackup "$BACKUP_SOURCE" "$BACKUP_DESTINATION" "$BACKUP_FILENAME" "$CONFIG_FILE";;
  backup-increment)
    ValidateBackupParent "$BACKUP_PARENT" "$BACKUP_DESTINATION"
    IncrementalBackup "$BACKUP_SOURCE" "$BACKUP_DESTINATION" "$BACKUP_FILENAME" "$CONFIG_FILE" "$BACKUP_PARENT";;
  list)
    list "$BACKUP_DESTINATION" "$BACKUP_FILENAME";;
  restore)
    GetCloseSnap "$ARGUMENT" "$BACKUP_DESTINATION" 1 "$BACKUP_FILENAME";;
  show)
    GetCloseSnap "$ARGUMENT" "$BACKUP_DESTINATION" 0;;
  *)
    [ -z "$ACTION" ] && MsgType "No action supplied!" 1
    MsgType "Unknown action! ($ACTION)" 1
esac

exit 0
