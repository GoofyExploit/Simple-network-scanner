#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

trap ctrl_c INT

ctrl_c() {
    echo -e "\n${RED}Scan interrupted by user. Exiting...${NC}"
    exit 1
}

banner() {
    echo -e "${GREEN}"
    echo "███████  ██████  █████  ███    ██"
    echo "██      ██      ██   ██ ████   ██"
    echo "█████   ██      ███████ ██ ██  ██"
    echo "██      ██      ██   ██ ██  ██ ██"
    echo "██       ██████ ██   ██ ██   ████"
    echo -e "${NC}"
}

COUNT_ONLY=0
NUM_IPS=256

usage() {
    echo "Usage: $0 [--count] [--number N]"
    echo "  --count      Show only the number of active hosts"
    echo "  --number N   Number of IPs to scan (default 256)"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --count)
            COUNT_ONLY=1
            shift
            ;;
        --number)
            if [[ $2 =~ ^[0-9]+$ ]]; then
                NUM_IPS=$2
                shift 2
            else
                echo "Error: --number requires an integer argument."
                usage
            fi
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

banner

interface=$(ip route | grep default | awk '{print $5}')

subnet=$(ip -o -f inet addr show $interface | awk '{print $4}' | cut -d/ -f1 | cut -d. -f1-3)

echo "Scanning subnet: $subnet.0 (up to $NUM_IPS hosts)"

active_hosts=0

for i in $(seq 1 $NUM_IPS); do
    ip="$subnet.$i"
    ping -c 1 -W 1 $ip &> /dev/null
    if [ $? -eq 0 ]; then
        ((active_hosts++))
        if [ $COUNT_ONLY -eq 0 ]; then
            echo -e "${GREEN}[+] Host active: $ip${NC}"
        fi
    fi
done

echo -e "${GREEN}Total active hosts: $active_hosts${NC}"
