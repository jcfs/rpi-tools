#!/bin/sh

#constants
_BACKUP_DIR="/media/backup"

# variables
_dow=$(echo $(date +%A) | awk '{print tolower($0)}')
_hostname=$(hostname)
_backup_fname="$_BACKUP_DIR/$_dow-$_hostname.tar.gz"
_checksum_fname="$_BACKUP_DIR/$_dow-$_hostname"
_log_fname="$_BACKUP_DIR/backup.log"

echo "[$(date +%s)] Backup started : $_backup_fname at $(date +%H:%M:%S)" >> $_log_fname
tar -cvpzf $_backup_fname --one-file-system --exclude=/media/* / 2> /dev/null
md5sum $_backup_fname > $_checksum_fname 
echo "[$(date +%s)] Backup ended : $_backup_fname at $(date +%H:%M:%S)" >> $_log_fname

if hash copy-cmd 2> /dev/null; then
  echo "[$(date +%s)] Copy command found uploading file..." >> $_log_fname
  copy-cmd Cloud -username=$1 -password=$2 mkdir /backup/$_hostname 2> /dev/null
  copy-cmd Cloud -username=$1 -password=$2 put $_backup_fname /backup/$_hostname 2> /dev/null
  copy-cmd Cloud -username=$1 -password=$2 put $_checksum_fname /backup/$_hostname 2> /dev/null
  echo "[$(date +%s)] Done uploading file." >> $_log_fname
  rm -rf $_backup_fname $_checksum_fname
else
  echo "[$(date +%s)] Copy command not found not uploading file." >> $_log_fname

fi
