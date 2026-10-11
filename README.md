# Server Health Checker

## Overview
A Bash scripting project that monitors CPU, RAM, and disk usage on a Linux system and reports the overall server health.

## Features
- Monitors CPU usage
- Monitors RAM usage
- Monitors disk usage
- Compares resource usage against configurable thresholds
- Displays individual health statuses
- Calculates overall server status
- Saves reports with timestamps in a log file
- Includes basic error handling

## Requirements
- Linux or WSL Ubuntu
- Bash shell
- Standard Linux utilities: `top`, `free`, `df`, `awk`

## How to Run

```bash
bash server_health_checker.sh
```

## View Logs

```bash
tail -n 20 server_health.log
```

## Configuration
The CPU, RAM, and disk warning thresholds can be changed in the script.

## Learning Outcomes
- Bash variables and conditionals
- Command substitution
- Text processing with `awk`
- CPU, memory, and disk monitoring
- Error handling and exit codes
- Logging with timestamps

## Status
Completed — basic server resource monitoring and logging.
