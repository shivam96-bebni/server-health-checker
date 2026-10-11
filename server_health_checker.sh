#!/bin/bash

# ==================== DISK USAGE CHECK ====================

# Set the disk usage warning threshold
disk_threshold=80

# Get disk usage percentage for the root filesystem
disk_usage=$(df -h / | awk 'NR == 2 {print $5}')

# Stop the script if disk usage cannot be read
if [ -z "$disk_usage" ]
then
    echo "Unable to read disk usage"
    exit 1
fi

# Remove the percent sign so the value can be compared numerically
disk_usage=${disk_usage%\%}

# Set the initial disk health status
disk_status="HEALTHY"

# Compare disk usage against the warning threshold
if [ "$disk_usage" -gt "$disk_threshold" ]
then
    disk_status="WARNING"
else
    disk_status="HEALTHY"
fi


# ==================== CPU USAGE CHECK ====================

# Set the CPU usage warning threshold
cpu_Threshold=80

# Extract CPU idle percentage from the top command output
cpu_idle=$(top -bn1 | grep "%Cpu(s)" | awk '{ for (i=1; i<=NF; i++) if ($i ~ /^id,?$/) print $(i - 1)}')

# Stop the script if CPU idle percentage cannot be read
if [ -z "$cpu_idle" ]
then
    echo "Unable to read CPU idle value"
    exit 1
fi

# Calculate CPU usage by subtracting idle percentage from 100
cpu_usage=$(awk -v idle="$cpu_idle" 'BEGIN {print 100 - idle}')

# Stop the script if CPU usage could not be calculated
if [ -z "$cpu_usage" ]
then
    echo "Unable to calculate CPU usage"
    exit 1
fi

# Compare CPU usage against the warning threshold
if awk -v usage="$cpu_usage" -v threshold="$cpu_Threshold" 'BEGIN {exit !(usage > threshold)}'
then
    cpu_status="WARNING"
else
    cpu_status="HEALTHY"
fi


# ==================== RAM USAGE CHECK ====================

# Set the RAM usage warning threshold
Ram_Threshold=80

# Get used and total memory in MiB from the free command
Used_ram=$(free | awk 'NR == 2 {print $3 / 1024}')
Total_ram=$(free | awk 'NR == 2 {print $2 / 1024}')

# Stop the script if memory values cannot be read
if [ -z "$Used_ram" ] || [ -z "$Total_ram" ]
then
    echo "Unable to read memory values"
    exit 1
fi

# Calculate RAM usage percentage
Ram_usage=$(awk -v used="$Used_ram" -v Total="$Total_ram" 'BEGIN {print (used / Total) * 100}')

# Compare RAM usage against the warning threshold
if awk -v MEMORY="$Ram_usage" -v threshold="$Ram_Threshold" 'BEGIN {exit !(MEMORY > threshold)}'
then
    Ram_status="WARNING"
else
    Ram_status="HEALTHY"
fi


# ==================== OVERALL SERVER STATUS ====================

# Assume the server is healthy unless a resource exceeds its threshold
overall_status="HEALTHY"

# Mark the server as WARNING if any resource is in WARNING state
if [ "$cpu_status" = "WARNING" ] || [ "$Ram_status" = "WARNING" ] || [ "$disk_status" = "WARNING" ]
then
    overall_status="WARNING"
fi


# ==================== DISPLAY HEALTH REPORT ====================

# Print the server health report in the terminal
echo "========== SERVER HEALTH REPORT =========="
echo
echo "Disk usage: ${disk_usage}%"
echo "Threshold: ${disk_threshold}%"
echo "Disk Status: ${disk_status}"
echo "CPU USAGE: ${cpu_usage}%"
echo "CPU THRESHOLD: ${cpu_Threshold}%"
echo "CPU STATUS: ${cpu_status}"
echo ""
echo "USED RAM: ${Used_ram} MiB"
echo "TOTAL RAM: ${Total_ram} MiB"
echo "RAM USAGE: ${Ram_usage}%"
echo "RAM THRESHOLD: ${Ram_Threshold}%"
echo "RAM STATUS: ${Ram_status}"
echo ""
echo "OVERALL SERVER STATUS: ${overall_status}"
echo "==========================================="


# ==================== SAVE REPORT TO LOG FILE ====================

# Append the report and current timestamp to the log file
{
    echo "========== SERVER HEALTH REPORT =========="
    echo "$(date '+%F %T')"
    echo "Disk usage: ${disk_usage}%"
    echo "Threshold: ${disk_threshold}%"
    echo "Disk Status: ${disk_status}"
    echo "CPU USAGE: ${cpu_usage}%"
    echo "CPU THRESHOLD: ${cpu_Threshold}%"
    echo "CPU STATUS: ${cpu_status}"
    echo ""
    echo "USED RAM: ${Used_ram} MiB"
    echo "TOTAL RAM: ${Total_ram} MiB"
    echo "RAM USAGE: ${Ram_usage}%"
    echo "RAM THRESHOLD: ${Ram_Threshold}%"
    echo "RAM STATUS: ${Ram_status}"
    echo ""
    echo "OVERALL SERVER STATUS: ${overall_status}"
    echo "==========================================="
} >> server_health.log
