#!/usr/bin/env bash
set -euo pipefail

source ./lib/common.sh

log_info "Testing logging system"
log_ok "Everything works"
log_warn "This is a warning"
log_error "This is an error"
