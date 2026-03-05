#!/bin/bash

# ==========================================================
# Student Name: liat dalgo
# Student Code: s14
# Unit Code: TMagen773637
# Program Code: NX201
# Lecturer: remote control
# ==========================================================

# --- Configuration & Variables ---
# 
LOG_FILE="research_audit.log"
LOCAL_REPORTS="./remote_scan_results"
mkdir -p "$LOCAL_REPORTS"

# Colors for output
NC='\033[0m' 
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'

# --- Functions ---

# Function to log events with timestamps 
log_event() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# 1.1 & 1.2: Install dependencies if missing 
prepare_environment() {
    echo -e "${CYAN}[*] Verifying system dependencies...${NC}"
    local packages=("nmap" "whois" "sshpass" "tor" "curl" "geoip-bin")
    
    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q "$pkg"; then
            echo -e "${RED}[!] Installing missing package: $pkg${NC}"
            sudo apt-get install -y "$pkg" > /dev/null 2>&1
            log_event "Installed package: $pkg"
        fi
    done

    # Setup Nipe 
    if [ ! -d "nipe" ]; then
        echo -e "${CYAN}[*] Cloning Nipe repository...${NC}"
        git clone https://github.com/htrgouvea/nipe.git > /dev/null 2>&1
        cd nipe || exit
        sudo cpanm --installdeps . > /dev/null 2>&1
        sudo perl nipe.pl install > /dev/null 2>&1
        cd ..
        log_event "Nipe installed."
    fi
}

# 1.3 & 1.4: Anonymity Check 
ensure_anonymity() {
    echo -e "${CYAN}[*] Activating Nipe for anonymity...${NC}"
    cd nipe || exit
    sudo perl nipe.pl restart > /dev/null 2>&1
    sleep 5 # Allow time for circuit establishment
    
    local status=$(sudo perl nipe.pl status)
    local current_ip=$(curl -s https://ifconfig.me)
    # Extract country from geoip
    country=$(geoiplookup "$current_ip" | awk -F', ' '{print $2}')

    if [[ "$status" == *"true"* ]]; then
        echo -e "${GREEN}[+] Connection is Anonymous.${NC}"
        echo -e "${GREEN}[+] Spoofed Location: $country ($current_ip)${NC}"
        log_event "Anonymity verified. Location: $country"
        cd ..
    else
        echo -e "${RED}[!] ALERT: Connection is NOT anonymous. Exiting.${NC}"
        log_event "Security breach: Attempted scan without anonymity. Script terminated."
        cd ..
        exit 1
    fi
}

# --- Main Execution ---

# Header
echo -e "${CYAN}========================================"
echo -e "   NX201: REMOTE CONTROL AUTOMATION"
echo -e "========================================${NC}"

# Initializing
log_event "Script NX201 started."
prepare_environment
ensure_anonymity

# 1.5: User Input 
read -p "Enter Target IP/Domain to scan: " TARGET_ADDR
read -p "Enter Remote Server Username: " R_USER
read -p "Enter Remote Server IP: " R_HOST
read -s -p "Enter Remote Server Password: " R_PASS
echo -e "\n"

# 2.1: Remote Server Information
echo -e "${CYAN}[*] Fetching Remote Server Details...${NC}"
REMOTE_INFO=$(sshpass -p "$R_PASS" ssh -o StrictHostKeyChecking=no "$R_USER@$R_HOST" \
    "echo -n 'IP: ' && curl -s ifconfig.me && echo -n ' | Country: ' && geoiplookup \$(curl -s ifconfig.me) | awk -F', ' '{print \$2}' && echo -n ' | Uptime: ' && uptime -p")

echo -e "${GREEN}[+] Remote Host Info: $REMOTE_INFO${NC}"
log_event "Connected to remote server: $R_HOST"

# 2.2 & 2.3: Execute Remote Tasks 
echo -e "${CYAN}[*] Running Remote Whois and Nmap Scan on $TARGET_ADDR...${NC}"

sshpass -p "$R_PASS" ssh "$R_USER@$R_HOST" << EOF
    mkdir -p ~/remote_tmp
    whois "$TARGET_ADDR" > ~/remote_tmp/whois_report.txt
    nmap -Pn "$TARGET_ADDR" -oN ~/remote_tmp/nmap_report.txt
EOF
#EOF -- sends the "to-do list" to the server.


log_event "Remote scan tasks completed for $TARGET_ADDR"

# 3.1: Retrieve Results 
echo -e "${CYAN}[*] Transferring results to local machine...${NC}"
sshpass -p "$R_PASS" scp "$R_USER@$R_HOST:~/remote_tmp/*" "$LOCAL_REPORTS/" > /dev/null 2>&1

# Cleanup Remote Traces
sshpass -p "$R_PASS" ssh "$R_USER@$R_HOST" "rm -rf ~/remote_tmp"

# 4. Finish
echo -e "${GREEN}[+] Process Complete.${NC}"
echo -e "[*] Reports saved in: $LOCAL_REPORTS"
log_event "Results successfully retrieved. Script finished."
