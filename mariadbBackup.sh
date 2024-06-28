#!/bin/bash
#########################################################################
#Name: mariadbBackup.sh
#Subscription: This Script backups docker mysql or mariadb containers,
#or better dumps their database to a backup directory
##by David Zingg
##https://github.com/da4id
#
#License:
#This program is free software: you can redistribute it and/or modify it
#under the terms of the GNU General Public License as published by the
#Free Software Foundation, either version 3 of the License, or (at your option)
#any later version.
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
#or FITNESS FOR A PARTICULAR PURPOSE.
#########################################################################

if [[ -z BACKUPDIR ]]
then
  echo "BACKUPDIR not set -> exit"
  exit -1
fi

if [[ -z MYSQL_HOST ]]
then
  echo "MYSQL_HOST not set -> exit"
  exit -1
fi

if [[ -z MYSQL_DATABASE ]]
then
  echo "MYSQL_DATABASE not set -> exit"
  exit -1
fi

if [[ -z MYSQL_ROOT_PASSWORD ]]
then
  echo "MYSQL_ROOT_PASSWORD not set -> exit"
  exit -1
fi

# Timestamp definition for the backupfiles (example: $(date +"%Y%m%d%H%M") = 20200124-2034)
TIMESTAMP=$(date +"%Y%m%d%H%M")

BACKUP_FILE_NAME=$MYSQL_HOST-$MYSQL_DATABASE-$TIMESTAMP.sql.gz
BACKUP_FILE_FULL_PATH=$BACKUPDIR/$BACKUP_FILE_NAME
mkdir -p $BACKUPDIR
echo -e "create Backup for Database on Container:\n  * $MYSQL_DATABASE DB on $MYSQL_HOST to destination $BACKUP_FILE_FULL_PATH";
MYSQL_PWD=$MYSQL_ROOT_PASSWORD /usr/bin/mariadb-dump -h $MYSQL_HOST -u root $MYSQL_DATABASE | gzip > $BACKUP_FILE_FULL_PATH
echo -e "BACKUP created"

if [[ "$FTP_UPLOAD_ENABLED" == "true" ]]
then
  echo -e "UPLOAD Backup to FTP Server"
  curl -T $BACKUP_FILE_FULL_PATH --insecure $FTP_SERVER -u $FTP_USER:$FTP_PASSWD --ftp-ssl
  echo -e "Backup Uploaded"
fi

find $BACKUPDIR/ -type f -mtime +30 -delete

echo -e "\n$TIMESTAMP Backup for Databases completed\n"