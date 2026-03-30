#!/usr/bin/env bash
set -euo pipefail

# COLORS

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# LOGGING 

log_info() {
   printf "${BLUE}[INFO]${NC} %s %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

log_ok() {
    printf "${GREEN}[OK]${NC} %s %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

log_warn() {
    printf "${YELLOW}[WARN]${NC} %s %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

log_error() {
    printf "${RED}[ERROR]${NC} %s %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >&2
}

# ERROR HANDLING
handle_error() {
    log_error "$1"
    exit 1
}

# UTILITY FUNCTIONS

require_command() {
    # with -v we check if the command exists without executing it, and redirect output to /dev/null
    if ! command -v "$1" > /dev/null 2>&1; then
        handle_error "Required command '$1' not found. Please install it and try again."
    fi
}

require_file() {
    [[ -f "$1" ]] || handle_error "Required file '$1' not found. Please create it and try again."
}

require_directory() {
    [[ -d "$1" ]] || handle_error "Required directory '$1' not found. Please create it and try again."
}

