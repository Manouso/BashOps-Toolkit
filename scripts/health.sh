#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"

# DEFAULTS
INPUT_FILE=""
TIMEOUT=5

# USAGE
usage(){
    # <service> is the name of the service to check and <timeout> is the number of seconds to wait before timing out the health check.
    echo "Usage: $0 -f <service> [-t <timeout>]"
}

# PARSE ARGS
while getopts "f:t:h" opt; do
    case $opt in
        f) INPUT_FILE="$OPTARG" ;;
        t) TIMEOUT="$OPTARG" ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

# VALIDATE ARGS
# If the INPUT_FILE variable is empty, we call the usage function to display the usage message and exit with a status code of 1, indicating an error.
[[ -z "$INPUT_FILE" ]] && usage

require_file "$INPUT_FILE"

# required for curl command in health check
require_command "curl"

# HEALTH CHECK
log_info "Starting health checks..."

total_services=0
failed_services=0

# Read the input file line by line, splitting on the pipe character, and assign the first part to url and the second part to name
# IFS is the Internal Field Separator, which we set to | to split the line into url and name variables.
while IFS='|' read -r url name || [[ -n "$url" ]] || [[ -n "$name" ]]; do
    # If the url variable is empty, skip this iteration of the loop and continue with the next line in the input file.
    [[ -z "$url" ]] && continue

    total_services=$(( total_services + 1 )) # Increment the total_services counter for each service we check.

    # We use curl to check the health of the service at the specified url. The -s flag makes curl silent, the -f flag makes it fail on HTTP errors.
    if curl -sf --max-time "$TIMEOUT" "$url" > /dev/null 2>&1; then
        log_ok "Service "$name" ("$url") is healthy."
    else
        log_error "Service "$name" ("$url") is unhealthy."
        failed_services=$(( failed_services + 1 ))
    fi

# The done keyword indicates the end of the while loop, and the < "$INPUT_FILE" part tells the loop to read from the specified input file.
done < "$INPUT_FILE"

# SUMMARY
log_info "Health check completed. Total services: $total_services, Failed services: $failed_services."

success_services=$(( total_services - failed_services ))
echo "Successful to Total Services: $success_services/$total_services"

# If there are any failed services, we exit with a status code of 1 to indicate an error. Otherwise, we exit with a status code of 0 to indicate success.
if [[ "$failed_services" -gt 0 ]]; then
    exit 1
else
    exit 0
fi