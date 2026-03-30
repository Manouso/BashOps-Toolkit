#!/usr/bin/env bash
set -euo pipefail
source ./lib/common.sh

# IFS (Internal Field Separator) is a special variable in bash that defines the characters used to split a string into words.
IFS=',' read -r -a array <<< "${1:-}" # -r prevents backslash escapes from being interpreted, and -a allows us to read the input into an array.

log_info "Checking required commands..."

missing=0

for cmd in "${array[@]}"; do
    if command -v "$cmd" &> /dev/null; then
        log_ok "Command $cmd is available."
    else
        log_error "Command $cmd is missing."
        missing=$((missing + 1))
    fi
done

# Check if any commands were missing and exit with an error if so.
if [[ "$missing" -gt 0 ]]; then
    handle_error "One or more required commands are missing. Please install them and try again."
fi

log_ok "All required commands are available."

