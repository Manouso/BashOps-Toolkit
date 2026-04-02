#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"

# DEFAULTS
LOG_FILE=""
KEYWORD="ERROR"

# USAGE
usage(){
    echo "Usage: $0 -f <log_file> [-k <keyword>]"
}

# PARSE ARGUMENTS
while getopts "f:k:h" opt; do
    case $opt in
        f) LOG_FILE="$OPTARG" ;;
        k) KEYWORD="$OPTARG" ;;
        h) usage exit 0 ;;
        *) usage exit 1 ;;
    esac
done

[[ -z "$LOG_FILE" ]] && usage exit 1

# VALIDATE
require_file "$LOG_FILE"
require_command "grep"

# ANALYZE
log_info "Analyzing log file: $LOG_FILE for keyword: $KEYWORD"

# We use grep with -n to get line numbers, and we handle the case where no matches are found by using || true to prevent grep from exiting with a non-zero status
MATCHES=$(grep -n "$KEYWORD" "$LOG_FILE" || true)
COUNT=$(echo "$MATCHES" | wc -l || true)

log_info "Found $COUNT occurrences of '$KEYWORD' in $LOG_FILE"

if [[ $COUNT -gt 0 ]]; then
    log_info "Occurrences of '$KEYWORD' found in $LOG_FILE:"
    echo "$MATCHES"
else
    log_ok "No occurrences of '$KEYWORD' found in $LOG_FILE"
fi

log_info "Top repeated lines in $LOG_FILE:"

# We sort the matches, count unique occurrences, sort by frequency, and display the top 5
echo "$MATCHES" \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -n 5

log_ok "Analysis complete."