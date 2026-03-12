#!/bin/bash
set -e

########################################
# Configurable variables
########################################

LOG_FILE="${LOG_FILE:-/app/st.log}"
SCRIPT_PATH="${SCRIPT_PATH:-/app/st.sh}"

NETTEST_TIMER="${NETTEST_TIMER:-0}"   # minutes
CPU_UTIL="${CPU_UTIL:-50}"            # CPU usage %
MEM_UTIL="${MEM_UTIL:-50}"            # memory usage %

########################################
# Log function
########################################

log(){
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

########################################
# Create cron job
########################################

if [ -n "$NETTEST_TIMER" ]; then

    if [ "$NETTEST_TIMER" -eq 0 ]; then
        log "Interval is 0, no task will be created"

    elif [ "$NETTEST_TIMER" -le 59 ]; then

        CRON="*/${NETTEST_TIMER} * * * * bash $SCRIPT_PATH >> $LOG_FILE 2>&1"

        (crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH" ; echo "$CRON") | crontab -

        log "Cron job created: every ${NETTEST_TIMER} minutes"

    elif [ "$NETTEST_TIMER" -lt 1440 ]; then

        hour=$((NETTEST_TIMER / 60))
        minute=$((NETTEST_TIMER % 60))

        CRON="$minute */$hour * * * bash $SCRIPT_PATH >> $LOG_FILE 2>&1"

        (crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH" ; echo "$CRON") | crontab -

        log "Cron job created: every ${NETTEST_TIMER} minutes"

    else
        log "Interval limit exceeded"
    fi

    service cron restart

else
    log "NETTEST_TIMER is not set"
fi


########################################
# Speedtest
########################################

run_speedtest(){

    log "Speedtest started"

    RESULT=$(speedtest --single 2>&1)

    log "$RESULT"

    log "Speedtest finished"
}

run_speedtest


########################################
# Memory calculation
########################################

MemTotal=$(awk '/MemTotal/ {printf "%d\n",$2/1024}' /proc/meminfo)

MemUsage=$((MemTotal * MEM_UTIL / 100))

log "Starting CPU load: $CPU_UTIL%  Memory: ${MemUsage}MB"

########################################
# Start CPU / memory load
########################################

lb -c "$CPU_UTIL" -m "${MemUsage}MB" -r curve
