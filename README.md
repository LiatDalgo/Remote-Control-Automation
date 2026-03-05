NX201: Remote Control Automation & Anonymity
📖 Overview

This project is an advanced automation script designed for secure and anonymous remote reconnaissance. The tool ensures the operator's identity is protected by routing traffic through the Tor network before establishing an encrypted SSH tunnel to a remote server to perform scanning tasks.
⚙️ Key Features

    Anonymity Verification: Automatically installs and configures Nipe to route local traffic through Tor. The script will terminate immediately if a non-anonymous connection is detected.

    Geo-Location Tracking: Displays spoofed location details to confirm anonymity.

    Remote SSH Automation: Securely connects to a remote server using sshpass to execute commands without manual interaction.

    Automated Reconnaissance: Triggers remote Whois and Nmap scans from the remote host to hide the true origin of the scan.

    Secure Data Retrieval: Automatically transfers result logs (.txt) back to the local machine and cleans up traces on the remote server.

🛠️ Tools Used

    Automation: Bash Scripting.

    Anonymity: Nipe (Tor Network), GeoIP-bin.

    Networking: Nmap, Whois, SSH, SCP.

📸 System in Action

    Verifying Tor connection and spoofed IP location.

    Connecting to a remote server and initiating automated scans.
🚀 How to Run
Bash

# 1. Make the script executable
    chmod +x remote-scanner.sh

# 2. Run the tool
    ./remote-scanner.sh# Remote-Control-Automation
Automated remote reconnaissance tool with built-in anonymity verification. Uses Nipe (Tor network) for local proxying and executes remote Whois/Nmap scans via SSH automation. Developed as part of the NX201 program.
