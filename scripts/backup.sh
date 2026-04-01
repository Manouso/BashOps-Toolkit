#!/usr/bin/env bash
set -euo pipefail
source ./lib/common.sh

# Defaults
TARGET_DIR=""
MAX_BACKUPS=5
# dirname "$0" gives the directory of the currently running script, and we append /backups to it to define the backup directory.
BACKUP_DIR="$(dirname "$0")/backups"

# Usage (<directory> is required to specify the target directory to back up, while <max_backups> and <backup_dir> are optional parameters with default values.)
# -d <directory>: The directory to back up (required)
# -m <max_backups>: The maximum number of backups to keep (optional, default: 5)
# -b <backup_dir>: The directory where backups will be stored (optional, default: ./backups)
usage(){
    echo "Usage: $0 -d <directory> [-m <max_backups>]"
    exit 1
}

# Argument Parsing
while getopts "d:m:h" opt; do
    case ${opt} in
        d) TARGET_DIR="$OPTARG" ;; # -d option is used to specify the target directory to back up, and we store its value in the TARGET_DIR variable.
        m) MAX_BACKUPS="$OPTARG" ;; # -m option allows the user to specify the maximum number of backups to keep, and we store its value in the MAX_BACKUPS variable.
        h) usage ;; # Help option to display usage information
        *) usage ;; # Handle invalid options by displaying usage information
    esac
done

# Validation
require_directory "$TARGET_DIR" # Check if the target directory exists

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR" # Create the backup directory if it doesn't exist

# Create backup
TIMESTAMP=$(date +"%Y%m%d%H%M%S") # Generate a timestamp for the backup filename
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz" # Define the backup file path using the backup directory and timestamp

log_info "Creating backup of $TARGET_DIR at $BACKUP_FILE"

# tar command makes a compressed archive of the target directory.
tar -czf "$BACKUP_FILE" "$TARGET_DIR" 

# Backup count
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | wc -l) # Count the number of backup files in the backup directory

if [[ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]]; then
    log_warn "Maximum number of backups ($MAX_BACKUPS) exceeded. Rotating backups..."

    # List backup files sorted by modification time and skip the most recent ones based on the MAX_BACKUPS limit.
    ls -1t "$BACKUP_DIR"/backup_*.tar.gz |
        tail -n +$((MAX_BACKUPS + 1)) |
        xargs -r rm -f # Remove the old backup files that exceed the maximum limit.
fi

log_ok "Backup completed successfully. Current backup count: $BACKUP_COUNT"

