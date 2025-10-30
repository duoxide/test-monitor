#!/bin/bash
# Script: test-monitor.sh
# Purpose: Monitor "test" process and report status to API

monitor_test() {
	echo "Check started $(date '+%d-%m-%Y %H:%M:%S')"

    local LOG_FILE="/var/log/test-monitoring/monitoring.log"
    local STATE_FILE="$PWD/test-monitor.prevpid"
    local API_URL="https://test.com/monitoring/test/api"
	local PROCESS_NAME="test"

    # Ensure log file exists
	if [[ ! -f "$LOG_FILE" ]]; then
        touch "$LOG_FILE"
    fi

    # Get PID of the "test" process
    local PID
    PID=$(pgrep -x "$PROCESS_NAME")
	echo "PID of process $PROCESS_NAME is $PID"

    # If process is not running, do nothing
    if [[ -z "$PID" ]]; then
		echo "Process does not exist"
		echo "Check complete $(date '+%d-%m-%Y %H:%M:%S')"
        return 0
    fi

    # Read previous process PID
    local PREV_PID=""
    if [[ -f "$STATE_FILE" ]]; then
        PREV_PID=$(cat "$STATE_FILE")
    fi

    # If process restarted, log it
    if [[ "$PID" != "$PREV_PID" && -n "$PREV_PID" ]]; then
        echo "$(date '+%d-%m-%Y %H:%M:%S') - Process 'test' restarted (old PID: $PREV_PID, new PID: $PID)" >> "$LOG_FILE"
    fi

    # Save current process PID
    echo "$PID" > "$STATE_FILE"

    # Make POST request to API
    local HTTP_CODE
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$API_URL"  --connect-timeout 5 --max-time 10 || echo "000")

    # If API not responding or error
    if [[ "$HTTP_CODE" -ge 400 || "$HTTP_CODE" -eq 000 ]]; then
        echo "$(date '+%d-%m-%Y %H:%M:%S') - API error: HTTP $HTTP_CODE while contacting $API_URL" >> "$LOG_FILE"
    fi

	echo "Check complete $(date '+%d-%m-%Y %H:%M:%S')"
}

monitor_test