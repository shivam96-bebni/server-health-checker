#!/bin/bash 

disk_threshold=80
disk_usage=$(df -h / | awk 'NR == 2 {print $5}')

if [ -z "$disk_usage" ]
then
    echo "unable to read disk"
    exit 1
fi

disk_usage=${disk_usage%\%}
disk_status="HEALTHY"
if [ "$disk_usage" -gt "$disk_threshold" ]
then 
    
      disk_status="WARNING"
else 
     
      disk_status="HEALTHY"
fi

cpu_Threshold=80
cpu_idle=$(top -bn1 | grep "%Cpu(s)" | awk '{ for (i=1; i<=NF; i++) if ( $i ~ /^id,?$/) print $(i - 1)}')

if [ -z "$cpu_idle" ]
then
     echo "unable to read Cpu idle value:"
     exit 1
fi

cpu_usage=$(awk -v idle="$cpu_idle" 'BEGIN {print 100 - idle}')
cpu_status="HEALTHY"


if [ -z "$cpu_usage" ]
then
     echo "unable to read Cpu:"
     exit 1
fi

if awk -v usage="$cpu_usage" -v threshold="$cpu_Threshold" 'BEGIN {exit !( usage > threshold )}'
then
     cpu_status="WARNING"
else
     cpu_status="HEALTHY"
fi

Ram_Threshold=80
Used_ram=$(free  | awk 'NR == 2 {print $3 / 1024}')
Total_ram=$(free  | awk 'NR == 2 {print $2 / 1024}')

if [  -z "$Used_ram" ] || [ -z "$Total_ram" ]
then 
     echo "unable to read memory"
     exit 1
fi

Ram_usage=$( awk -v used="$Used_ram" -v Total="$Total_ram" 'BEGIN {print (used / Total) * 100 }')
Ram_status="HEALTHY"

if awk -v MEMORY="$Ram_usage" -v threshold="$Ram_Threshold" 'BEGIN {exit !( MEMORY > threshold)}'
then
    Ram_status="WARNING"
else
     Ram_status="HEALTHY"
fi

overall_status="HEALTHY"

if [ "$cpu_status" = "WARNING" ] || [ "$Ram_status" = "WARNING" ] || [ "$disk_status" = "WARNING" ]
then
    overall_status="WARNING"
fi


echo "========== SERVER HEALTH REPORT =========="
echo
echo "Disk usage: ${disk_usage}%"
echo "Threshold: ${disk_threshold}%"
echo "Disk Status: ${disk_status}"
echo "CPU USAGE: ${cpu_usage}%"
echo "CPU THRESHOLD: ${cpu_Threshold}%"
echo "CPU STATUS: ${cpu_status}"
echo ""
echo "USED RAM: ${Used_ram} MB"
echo "TOTAL RAM: ${Total_ram} MB"
echo "RAM USAGE: ${Ram_usage}%"
echo "RAM THRESHOLD: ${Ram_Threshold}%"
echo "RAM STATUS: ${Ram_status}"
echo ""
echo "OVERALL SERVER STATUS: ${overall_status}"
echo "==========================================="

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
echo "USED RAM: ${Used_ram} MB"
echo "TOTAL RAM: ${Total_ram} MB"
echo "RAM USAGE: ${Ram_usage}%"
echo "RAM THRESHOLD: ${Ram_Threshold}%"
echo "RAM STATUS: ${Ram_status}"
echo ""
echo "OVERALL SERVER STATUS: ${overall_status}"
echo "==========================================="
} >> server_health.log