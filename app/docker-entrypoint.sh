#!/bin/bash
set -e

########################################
# Config
########################################

NETTEST_TIMER_RAW=${NETTEST_TIMER:-60}

CPU_UTIL="${CPU_UTIL:-50}"
MEM_UTIL="${MEM_UTIL:-50}"
SCRIPT_PATH="${SCRIPT_PATH:-/app/st.sh}"
LOG_FILE="${LOG_FILE:-/app/st.log}"

########################################
# Log function
########################################

log(){
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

########################################
# Memory calculation
########################################

MemTotal=$(awk '/MemTotal/ {printf "%d\n",$2/1024}' /proc/meminfo)
MemUsage=$((MemTotal * MEM_UTIL / 100))

log "CPU load target: ${CPU_UTIL}%"
log "Memory load target: ${MemUsage}MB"
log "St interval: ${NETTEST_TIMER} minutes"

########################################
# Start CPU / memory load
########################################

log "Starting CPU/Memory load..."

lb -c "$CPU_UTIL" -m "${MemUsage}MB" -r curve &

########################################
########################################

while true
do
    RANDOM_MIN=$((RANDOM % 5 + 1)) # 1~5
    NETTEST_TIMER=$((NETTEST_TIMER_RAW + RANDOM_MIN))

    log "St started"

    if RESULT=$(bash "$SCRIPT_PATH" 2>&1); then
        echo "$RESULT"
    else
        log "St failed"
        echo "$RESULT"
    fi

    log "St finished"

    log "Sleeping ${NETTEST_TIMER} minutes..."

    sleep $((NETTEST_TIMER * 60))
done